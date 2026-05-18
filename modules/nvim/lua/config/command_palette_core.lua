local M = {}

local source_sections  -- forward declaration; assigned after collection functions

local valid_actions = {
  execute = true,
  edit = true,
}

local namespace = vim.api.nvim_create_namespace('config.command_palette')

local category_labels = {
  abbreviation = '略語',
  argument = '引数',
  autocmd = '自動CMD',
  buffer = 'バッファ',
  build = 'ビルド',
  command = 'コマンド',
  debug = 'デバッグ',
  diagnostic = '診断',
  diff = '差分',
  directory = 'ディレクトリ',
  edit = '編集',
  export = '書き出し',
  external = '外部',
  file = 'ファイル',
  filetype = 'ファイル種別',
  fold = '折り畳み',
  format = '整形',
  git = 'Git',
  help = 'ヘルプ',
  history = '履歴',
  insert = '入力',
  keymap = 'キー',
  locale = '言語',
  location = 'Location',
  lsp = 'LSP',
  mark = 'マーク',
  menu = 'メニュー',
  mode = 'モード',
  modifier = '修飾',
  navigation = '移動',
  option = '設定',
  outline = 'アウトライン',
  picker = '検索UI',
  plugin = 'プラグイン',
  preview = 'プレビュー',
  profile = '計測',
  quickfix = 'Quickfix',
  quit = '終了',
  register = 'レジスタ',
  script = 'スクリプト',
  search = '検索',
  security = '信頼',
  session = 'セッション',
  spelling = 'スペル',
  syntax = '構文',
  tab = 'タブ',
  table = '表',
  tag = 'タグ',
  terminal = '端末',
  test = 'テスト',
  textobject = 'テキスト対象',
  treesitter = '構文木',
  ui = '表示',
  undo = '取り消し',
  view = '閲覧',
  window = 'ウィンドウ',
}

local category_priority = {
  file = 10,
  buffer = 20,
  search = 30,
  git = 40,
  window = 50,
  tab = 60,
  diagnostic = 70,
  lsp = 80,
  treesitter = 90,
  picker = 100,
  help = 110,
  navigation = 120,
  edit = 130,
  undo = 140,
  view = 150,
  quickfix = 160,
  location = 170,
  outline = 180,
  option = 190,
  keymap = 700,
  menu = 710,
  abbreviation = 720,
  script = 800,
  command = 850,
  external = 900,
}

local command_priority = {
  CommandPalette = 0,
  write = 1,
  update = 2,
  wq = 3,
  xit = 4,
  edit = 5,
  enew = 6,
  saveas = 7,
  quit = 8,
  qall = 9,
  buffers = 10,
  bnext = 11,
  bprevious = 12,
  nohlsearch = 13,
  grep = 14,
  vimgrep = 15,
  help = 16,
  Pick = 17,
  DiffviewOpen = 18,
  DiffviewFileHistory = 19,
  Neogit = 20,
  Trouble = 21,
  checkhealth = 22,
  LspInfo = 23,
  Mason = 24,
  TSInstallInfo = 25,
  AerialToggle = 26,
  UndotreeToggle = 27,
  Goyo = 28,
  terminal = 29,
  split = 30,
  vsplit = 31,
  tabnew = 32,
  oldfiles = 33,
  pwd = 34,
  messages = 35,
  registers = 36,
  marks = 37,
  changes = 38,
  jumps = 39,
}

local mode_labels = {
  n = 'N',
  x = 'V',
  s = 'S',
  i = 'I',
  c = 'C',
  t = 'T',
  o = 'O',
}

local mode_names = {
  n = 'ノーマル',
  x = 'ビジュアル',
  s = '選択',
  i = '挿入',
  c = 'コマンドライン',
  t = '端末',
  o = 'オペレータ待ち',
}

local keymap_modes = { 'n', 'x', 's', 'i', 'c', 't', 'o' }

local search_field_order = {
  'command',
  'label',
  'description',
  'category',
  'mode',
  'key',
  'tag',
  'source_command',
  'aliases',
}

local search_field_weight = {
  command = 0,
  key = 5,
  tag = 10,
  label = 20,
  source_command = 30,
  aliases = 50,
  description = 80,
  category = 120,
  mode = 160,
}

local search_query_variants = {
  jump = { 'ジャンプ' },
  jumps = { 'ジャンプ' },
  jumplist = { 'ジャンプリスト' },
  definition = { '定義' },
  define = { '定義', '#define' },
  tag = { 'タグ' },
  mark = { 'マーク' },
  search = { '検索' },
  save = { '保存' },
  file = { 'ファイル' },
  buffer = { 'バッファ' },
  window = { 'ウィンドウ' },
  tab = { 'タブ' },
  help = { 'ヘルプ' },
}

local ignored_rhs_commands = {
  call = true,
  lua = true,
  normal = true,
}

local builtin_key_command_by_tag = {
  n = {
    ['!'] = '!',
    ['!!'] = '!',
    ['&'] = 'substitute',
    ['@'] = '@',
    ['@@'] = '@',
    ['<'] = '<',
    ['<<'] = '<',
    ['='] = '=',
    ['=='] = '=',
    ['>'] = '>',
    ['>>'] = '>',
    ['C'] = 'change',
    ['D'] = 'delete',
    ['J'] = 'join',
    ['P'] = 'put',
    ['S'] = 'change',
    ['X'] = 'delete',
    ['Y'] = 'yank',
    ['ZQ'] = 'quit',
    ['ZZ'] = 'xit',
    ['CTRL-R'] = 'redo',
    ['CTRL-T'] = 'pop',
    ['CTRL-]'] = 'tag',
    ['<Del>'] = 'delete',
    ['c'] = 'change',
    ['cc'] = 'change',
    ['d'] = 'delete',
    ['dd'] = 'delete',
    ['gJ'] = 'join',
    ['m'] = 'mark',
    ['p'] = 'put',
    ['s'] = 'change',
    ['u'] = 'undo',
    ['x'] = 'delete',
    ['y'] = 'yank',
    ['yy'] = 'yank',
    ['~'] = '~',
    ['CTRL-W_c'] = 'close',
    ['CTRL-W_n'] = 'new',
    ['CTRL-W_o'] = 'only',
    ['CTRL-W_q'] = 'quit',
    ['CTRL-W_s'] = 'split',
    ['CTRL-W_v'] = 'vsplit',
    ['CTRL-W_z'] = 'pclose',
  },
  x = {
    ['v_!'] = '!',
    ['v_<'] = '<',
    ['v_='] = '=',
    ['v_>'] = '>',
    ['v_C'] = 'change',
    ['v_D'] = 'delete',
    ['v_J'] = 'join',
    ['v_P'] = 'put',
    ['v_S'] = 'change',
    ['v_X'] = 'delete',
    ['v_Y'] = 'yank',
    ['v_c'] = 'change',
    ['v_d'] = 'delete',
    ['v_gJ'] = 'join',
    ['v_p'] = 'put',
    ['v_s'] = 'change',
    ['v_x'] = 'delete',
    ['v_y'] = 'yank',
    ['v_~'] = '~',
  },
}

local index_mode_markers = {
  { marker = '*insert-index*', mode = 'i' },
  { marker = '*normal-index*', mode = 'n' },
  { marker = '*operator-pending-index*', mode = 'o' },
  { marker = '*visual-index*', mode = 'x' },
  { marker = '*ex-edit-index*', mode = 'c' },
}

local function source_file_path()
  local paths = vim.api.nvim_get_runtime_file('lua/config/command_palette_source.lua', false)
  if paths[1] then
    return paths[1]
  end

  local current = debug.getinfo(1, 'S').source:gsub('^@', '')
  return current:gsub('command_palette_core%.lua$', 'command_palette_source.lua')
end

local function command_palette_file_path()
  local paths = vim.api.nvim_get_runtime_file('lua/config/command_palette.lua', false)
  if paths[1] then
    return paths[1]
  end

  local current = debug.getinfo(1, 'S').source:gsub('^@', '')
  return current:gsub('command_palette_core%.lua$', 'command_palette.lua')
end

local function is_non_empty_string(value)
  return type(value) == 'string' and value ~= ''
end

local function add_search_value(fields, name, value)
  if not is_non_empty_string(value) then
    return
  end

  fields[name] = fields[name] or {}
  table.insert(fields[name], value)
end

local function build_search_fields(entry)
  local fields = {}
  for _, name in ipairs(search_field_order) do
    fields[name] = {}
  end

  add_search_value(fields, 'command', entry.command)
  add_search_value(fields, 'label', entry.label)
  add_search_value(fields, 'description', entry.description)
  add_search_value(fields, 'category', entry.category)
  add_search_value(fields, 'mode', entry.mode)
  add_search_value(fields, 'key', entry.key)
  add_search_value(fields, 'tag', entry.tag)
  add_search_value(fields, 'source_command', entry.source_command)

  if type(entry.aliases) == 'table' then
    for _, alias in ipairs(entry.aliases) do
      add_search_value(fields, 'aliases', alias)
    end
  end

  if type(entry.keys) == 'table' then
    for _, keymap in ipairs(entry.keys) do
      local mode = keymap.mode
      local mode_label = mode_labels[mode]
      add_search_value(fields, 'mode', mode)
      add_search_value(fields, 'mode', mode_label)
      add_search_value(fields, 'key', keymap.key)
    end
  end

  return fields
end

local function search_text_from_fields(fields)
  local parts = {}
  for _, name in ipairs(search_field_order) do
    vim.list_extend(parts, fields[name] or {})
  end

  return table.concat(vim.tbl_filter(is_non_empty_string, parts), ' ')
end

local function sorted_copy(values)
  local copy = vim.deepcopy(values)
  table.sort(copy, function(left, right)
    local left_lower = left:lower()
    local right_lower = right:lower()
    if left_lower == right_lower then
      return left < right
    end
    return left_lower < right_lower
  end)
  return copy
end

local function empty_palette()
  local palette = {}
  for _, section in ipairs(source_sections) do
    palette[section.name] = {}
  end
  return palette
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function load_lua_file(path)
  local chunk, load_error = loadfile(path)
  if chunk == nil then
    error(load_error, 0)
  end

  local ok, value = pcall(chunk)
  if not ok then
    error(value, 0)
  end

  return value
end

local function normalize_source(source)
  if type(source) ~= 'table' then
    error('command_palette_source.lua がテーブルを返していません', 0)
  end

  local result = {}
  for _, section in ipairs(source_sections) do
    local section_data = source[section.name]
    -- Backward compat: old source files had commands as the root table
    if section.name == 'commands' and section_data == nil and source.commands == nil then
      section_data = source
    end
    if type(section_data) ~= 'table' then
      section_data = {}
    end
    result[section.name] = section_data
  end
  return result
end

local function normalize_palette(palette)
  if type(palette) ~= 'table' then
    return empty_palette()
  end

  local result = {}
  for _, section in ipairs(source_sections) do
    local section_data = palette[section.name]
    -- Backward compat: old palette files had commands as the root table
    if section.name == 'commands' and section_data == nil and palette.commands == nil then
      section_data = palette
    end
    if type(section_data) ~= 'table' then
      section_data = {}
    end
    result[section.name] = section_data
  end
  return result
end

local function read_source_file(path)
  path = path or source_file_path()
  if not file_exists(path) then
    error('command_palette_source.lua がありません。先に候補一覧を生成してください', 0)
  end

  return normalize_source(load_lua_file(path))
end

local function read_palette_file(path)
  path = path or command_palette_file_path()
  if not file_exists(path) then
    return empty_palette()
  end

  return normalize_palette(load_lua_file(path))
end

local function build_search_text(entry)
  entry.search_fields = build_search_fields(entry)
  return search_text_from_fields(entry.search_fields)
end

local function key_id(key)
  return key.mode .. '\t' .. key.key
end

local function builtin_key_source_id(item)
  return table.concat({ item.mode or '', item.tag or '', item.key or '' }, '\t')
end

local function builtin_key_source_label(item)
  local values = {
    item.source_command,
    item.mode,
    item.key,
    item.tag,
  }
  local label = table.concat(vim.tbl_filter(is_non_empty_string, values), ' ')
  if label ~= '' then
    return label
  end
  return builtin_key_source_id(item)
end

local function display_width(text)
  return vim.fn.strdisplaywidth(text)
end

local function truncate_display(text, width)
  if display_width(text) <= width then
    return text
  end

  if width <= 1 then
    return ''
  end

  local result = ''
  local limit = width - 1
  for index = 0, vim.fn.strchars(text) - 1 do
    local char = vim.fn.strcharpart(text, index, 1)
    if display_width(result .. char) > limit then
      break
    end
    result = result .. char
  end

  return result .. '…'
end

local function pad_display(text, width)
  local truncated = truncate_display(text, width)
  return truncated .. string.rep(' ', math.max(width - display_width(truncated), 0))
end

local function display_layout(buf_id)
  local win_id = vim.fn.bufwinid(buf_id)
  if win_id == -1 then
    win_id = 0
  end

  local width = math.max(vim.api.nvim_win_get_width(win_id), 80)

  if width < 100 then
    return {
      label = 18,
      command = 18,
      mode = 4,
      key = 14,
      action = 4,
      category = 8,
      line = width,
    }
  end

  return {
    label = 24,
    command = 26,
    mode = 6,
    key = 20,
    action = 4,
    category = 12,
    line = width,
  }
end

local function entry_category(entry)
  return category_labels[entry.category] or entry.category
end

local function entry_action(entry)
  if entry.action == 'execute' then
    return '実行'
  end
  return '入力'
end

local function append_unique(values, seen, value)
  if not is_non_empty_string(value) or seen[value] then
    return
  end

  seen[value] = true
  table.insert(values, value)
end

local function entry_modes(entry)
  if type(entry.keys) ~= 'table' or #entry.keys == 0 then
    return mode_labels[entry.mode] or entry.mode or ''
  end

  local values = {}
  local seen = {}
  for _, keymap in ipairs(entry.keys) do
    append_unique(values, seen, mode_labels[keymap.mode] or keymap.mode)
  end

  return table.concat(values, ', ')
end

local function entry_key(entry)
  if type(entry.keys) ~= 'table' or #entry.keys == 0 then
    return entry.key or ''
  end

  local values = {}
  local seen = {}
  for _, keymap in ipairs(entry.keys) do
    append_unique(values, seen, keymap.key)
  end

  return table.concat(values, ', ')
end

local function merge_keys(...)
  local result = {}
  local seen = {}

  for _, keys in ipairs({ ... }) do
    if type(keys) == 'table' then
      for _, key in ipairs(keys) do
        if is_non_empty_string(key.mode) and is_non_empty_string(key.key) then
          local id = key_id(key)
          if not seen[id] then
            seen[id] = true
            table.insert(result, {
              mode = key.mode,
              key = key.key,
            })
          end
        end
      end
    end
  end

  return result
end

local function display_segments(entry, layout)
  local label = pad_display(entry.label, layout.label)
  local command_text = entry.kind == 'builtin_key' and (entry.tag or entry.key or '') or (':' .. entry.command)
  local command = pad_display(command_text, layout.command)
  local mode = pad_display(entry_modes(entry), layout.mode)
  local key = pad_display(entry_key(entry), layout.key)
  local action = pad_display(entry_action(entry), layout.action)
  local category = pad_display(entry_category(entry), layout.category)
  local prefix = table.concat({ label, command, mode, key, action, category }, '  ')
  local description_width = math.max(layout.line - display_width(prefix) - 2, 12)
  local description = truncate_display(entry.description, description_width)

  return {
    line = prefix .. '  ' .. description,
    label = label,
    command = command,
    mode = mode,
    key = key,
    action = action,
    category = category,
  }
end

local function add_highlight(buf_id, line_index, start_col, text, highlight)
  vim.api.nvim_buf_add_highlight(buf_id, namespace, highlight, line_index, start_col, start_col + #text)
  return start_col + #text
end

local function add_query_highlights(buf_id, line_index, line, query)
  if type(query) ~= 'table' then
    return
  end

  local lower_line = line:lower()
  for _, part in ipairs(query) do
    if part ~= '' then
      local start_col, end_col = lower_line:find(part:lower(), 1, true)
      while start_col do
        vim.api.nvim_buf_add_highlight(buf_id, namespace, 'MiniPickMatchRanges', line_index, start_col - 1, end_col)
        start_col, end_col = lower_line:find(part:lower(), end_col + 1, true)
      end
    end
  end
end

local function show_items(buf_id, items, query)
  local layout = display_layout(buf_id)
  local display_items = vim.tbl_map(function(entry) return display_segments(entry, layout) end, items)
  local lines = vim.tbl_map(function(item) return item.line end, display_items)

  vim.api.nvim_set_option_value('modifiable', true, { buf = buf_id })
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf_id })
  vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)

  for index, item in ipairs(display_items) do
    local line_index = index - 1
    local col = 0

    col = add_highlight(buf_id, line_index, col, item.label, 'Title')
    col = col + 2
    col = add_highlight(buf_id, line_index, col, item.command, 'Function')
    col = col + 2
    col = add_highlight(buf_id, line_index, col, item.mode, 'ModeMsg')
    col = col + 2
    col = add_highlight(buf_id, line_index, col, item.key, 'Special')
    col = col + 2
    col = add_highlight(buf_id, line_index, col, item.action, item.action:match('実行') and 'DiagnosticOk' or 'DiagnosticWarn')
    col = col + 2
    col = add_highlight(buf_id, line_index, col, item.category, 'Type')
    col = col + 2
    vim.api.nvim_buf_add_highlight(buf_id, namespace, 'Comment', line_index, col, -1)
    add_query_highlights(buf_id, line_index, item.line, query)
  end
end

local function item_priority(item)
  local command = item.command or item.tag or item.key or ''
  if command_priority[command] ~= nil then
    return command_priority[command] - 1000
  end

  local priority = category_priority[item.category] or 500
  if command:match('^%p+$') then
    priority = priority + 1000
  end
  return priority
end

local function sort_items(items)
  table.sort(items, function(left, right)
    local left_priority = item_priority(left)
    local right_priority = item_priority(right)
    if left_priority ~= right_priority then
      return left_priority < right_priority
    end

    if left.label ~= right.label then
      return left.label < right.label
    end

    return (left.command or left.tag or left.key or '') < (right.command or right.tag or right.key or '')
  end)
  return items
end

local function command_lookup(commands)
  local lookup = {}
  for _, command in ipairs(commands) do
    lookup[command] = true
    lookup[command:lower()] = true
  end
  return lookup
end

local function parse_index_line(line)
  local tag, rest = line:match('^|([^|]+)|%s+(.*)$')
  if tag == nil then
    return nil
  end

  local columns = {}
  for column in rest:gmatch('[^\t]+') do
    table.insert(columns, vim.trim(column))
  end

  local key = columns[1]
  local description = nil
  if #columns >= 3 and columns[2]:match('^%d+$') then
    description = table.concat(vim.list_slice(columns, 3), ' ')
  elseif #columns >= 2 then
    description = table.concat(vim.list_slice(columns, 2), ' ')
  else
    key, description = rest:match('^(.-)%s%s+(.*)$')
    if key == nil then
      key, description = rest:match('^(%S+)%s+(.*)$')
    end
  end
  if key == nil then
    return nil
  end

  description = description:gsub('^%d%s+', '')
  description = vim.trim(description)

  return {
    tag = tag,
    key = vim.trim(key),
    description = description,
  }
end

local function builtin_command_for_index_item(item, commands)
  local by_mode = builtin_key_command_by_tag[item.mode]
  if by_mode == nil then
    return nil
  end

  local command = by_mode[item.tag]
  if command ~= nil and commands[command] then
    return command
  end

  return nil
end

local function index_ex_command_name(value)
  if type(value) ~= 'string' or not vim.startswith(value, ':') then
    return nil
  end

  local command = value:sub(2):gsub('%[([^%]]*)%]', '%1')
  return command:match('^([%w_#&!<>=@*]+)')
end

local function duplicates_ex_command(item, commands)
  for _, value in ipairs({ item.tag, item.key }) do
    local command = index_ex_command_name(value)
    if command ~= nil and commands[command:lower()] then
      return true
    end
  end

  return false
end

local function is_help_reference(item)
  return item.mode == 'c' and vim.startswith(item.tag, ':')
end

local function read_builtin_key_source(commands)
  local runtime = vim.fn.expand('$VIMRUNTIME')
  local path = runtime .. '/doc/index.txt'
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return {}
  end

  local source = {}
  local seen = {}
  local mode = nil
  for _, line in ipairs(lines) do
    for _, marker in ipairs(index_mode_markers) do
      if line:find(marker.marker, 1, true) then
        mode = marker.mode or nil
      end
    end

    if mode ~= nil then
      local item = parse_index_line(line)
      if item ~= nil then
        item.mode = mode
        if not duplicates_ex_command(item, commands) and not is_help_reference(item) then
          item.source_command = builtin_command_for_index_item(item, commands)
          local id = builtin_key_source_id(item)
          if not seen[id] then
            seen[id] = true
            table.insert(source, item)
          end
        end
      end
    end
  end

  table.sort(source, function(left, right)
    if left.mode ~= right.mode then
      return left.mode < right.mode
    end
    if left.tag ~= right.tag then
      return left.tag < right.tag
    end
    return left.key < right.key
  end)

  return source
end

local function normalize_lhs(lhs)
  local leader = vim.g.mapleader or '\\'
  local localleader = vim.g.maplocalleader or leader

  if leader ~= '' and vim.startswith(lhs, leader) then
    return '<leader>' .. lhs:sub(#leader + 1)
  end
  if localleader ~= '' and vim.startswith(lhs, localleader) then
    return '<localleader>' .. lhs:sub(#localleader + 1)
  end

  return lhs
end

local function command_from_token(token, command_lookup)
  if token == nil or token == '' or ignored_rhs_commands[token] then
    return nil
  end
  if command_lookup[token] then
    return token
  end

  local candidates = vim.fn.getcompletion(token, 'command')
  if #candidates == 1 and command_lookup[candidates[1]] and not ignored_rhs_commands[candidates[1]] then
    return candidates[1]
  end

  return nil
end

local function rhs_commands(rhs, command_lookup)
  if not is_non_empty_string(rhs) then
    return {}
  end

  local body = rhs:match('^<Cmd>(.-)<CR>') or rhs:match('^:(.-)<CR>')
  if body == nil then
    return {}
  end

  local result = {}
  for part in body:gmatch('[^|]+') do
    part = vim.trim(part)
    part = part:gsub('^<C%-U>', '')
    part = part:gsub('^%s*silent!?%s+', '')
    part = part:gsub('^%s*%d+', '')
    part = part:gsub('^%s*%%', '')
    local token = part:match('^%s*([%a][%w]*)')
    local command = command_from_token(token, command_lookup)
    if command ~= nil then
      table.insert(result, command)
    end
  end

  return result
end

local function add_keymap(index, seen, command, mapping)
  local lhs = mapping.lhs
  if not is_non_empty_string(lhs) then
    return
  end

  local key = normalize_lhs(lhs)
  local mode = mapping.mode
  local seen_key = command .. '\t' .. mode .. '\t' .. key
  if seen[seen_key] then
    return
  end

  seen[seen_key] = true
  index[command] = index[command] or {}
  table.insert(index[command], {
    key = key,
    mode = mode,
  })
end

local function keymap_index(entries)
  local command_lookup = {}
  for _, entry in ipairs(entries) do
    if type(entry) == 'table' and is_non_empty_string(entry.command) then
      command_lookup[entry.command] = true
    end
  end

  local index = {}
  local seen = {}
  for _, mode in ipairs(keymap_modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, mode))

    for _, mapping in ipairs(maps) do
      mapping.mode = mapping.mode or mode
      for _, command in ipairs(rhs_commands(mapping.rhs, command_lookup)) do
        add_keymap(index, seen, command, mapping)
      end
    end
  end

  return index
end

local function is_command_rhs(rhs)
  if not is_non_empty_string(rhs) then
    return false
  end
  return rhs:match('^<Cmd>') ~= nil or rhs:match('^:') ~= nil
end

local function read_user_keymap_source()
  local entries = {}
  local seen = {}
  for _, mode in ipairs(keymap_modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, mode))
    for _, mapping in ipairs(maps) do
      local lhs = mapping.lhs
      if is_non_empty_string(lhs) and is_non_empty_string(mapping.desc) then
        local key = normalize_lhs(lhs)
        if not key:find('<Plug>', 1, true)
          and not key:find('<SNR>', 1, true)
          and not is_command_rhs(mapping.rhs) then
          local mode_key = (mapping.mode or mode) .. '\t' .. key
          if not seen[mode_key] then
            seen[mode_key] = true
            table.insert(entries, {
              mode = mapping.mode or mode,
              key = key,
              desc = mapping.desc,
            })
          end
        end
      end
    end
  end
  table.sort(entries, function(a, b)
    if a.mode ~= b.mode then
      return a.mode < b.mode
    end
    return a.key < b.key
  end)
  return entries
end

-- Source section registry: each section defines how entries are collected,
-- serialized to the source file, identified for coverage comparison, and
-- reported.  Adding a new source type means adding one entry here.
source_sections = {
  {
    name = 'commands',
    label = 'Exコマンド',
    collect = function()
      return sorted_copy(vim.fn.getcompletion('', 'command'))
    end,
    source_entry_id = function(entry)
      return entry
    end,
    source_entry_label = function(entry)
      return entry
    end,
    palette_entry_id = function(entry)
      if type(entry) ~= 'table' or not is_non_empty_string(entry.command) then
        return nil
      end
      return entry.command
    end,
    -- Serialization for source file
    write_header = function(lines)
      table.insert(lines, '  commands = {')
    end,
    write_entry = function(lines, entry)
      table.insert(lines, ('    %q,'):format(entry))
    end,
    write_footer = function(lines)
      table.insert(lines, '  },')
    end,
  },
  {
    name = 'builtin_keys',
    label = 'index.txt 組み込みキー',
    collect = function(source)
      local commands = (source or {}).commands or {}
      return read_builtin_key_source(command_lookup(commands))
    end,
    source_entry_id = function(entry)
      return table.concat({ entry.mode or '', entry.tag or '', entry.key or '' }, '\t')
    end,
    source_entry_label = function(entry)
      local values = { entry.source_command, entry.mode, entry.key, entry.tag }
      local label = table.concat(vim.tbl_filter(is_non_empty_string, values), ' ')
      if label ~= '' then
        return label
      end
      return table.concat({ entry.mode or '', entry.tag or '', entry.key or '' }, '\t')
    end,
    palette_entry_id = function(entry)
      if type(entry) ~= 'table' then
        return nil
      end
      if not is_non_empty_string(entry.mode) or not is_non_empty_string(entry.tag) or not is_non_empty_string(entry.key) then
        return nil
      end
      return table.concat({ entry.mode, entry.tag, entry.key }, '\t')
    end,
    write_header = function(lines)
      table.insert(lines, '  builtin_keys = {')
    end,
    write_entry = function(lines, entry)
      table.insert(lines, '    {')
      table.insert(lines, ('      mode = %q,'):format(entry.mode))
      table.insert(lines, ('      key = %q,'):format(entry.key))
      table.insert(lines, ('      tag = %q,'):format(entry.tag))
      if entry.source_command ~= nil then
        table.insert(lines, ('      source_command = %q,'):format(entry.source_command))
      end
      table.insert(lines, ('      description = %q,'):format(entry.description))
      table.insert(lines, '    },')
    end,
    write_footer = function(lines)
      table.insert(lines, '  },')
    end,
  },
  {
    name = 'user_keymaps',
    label = 'ユーザーキーマップ',
    collect = function()
      return read_user_keymap_source()
    end,
    source_entry_id = function(entry)
      return table.concat({ entry.mode, entry.key }, '\t')
    end,
    source_entry_label = function(entry)
      return ('%s %s %s'):format(entry.mode, entry.key, entry.desc or '')
    end,
    palette_entry_id = function(entry)
      if type(entry) ~= 'table' then
        return nil
      end
      if not is_non_empty_string(entry.mode) or not is_non_empty_string(entry.key) then
        return nil
      end
      return table.concat({ entry.mode, entry.key }, '\t')
    end,
    write_header = function(lines)
      table.insert(lines, '  user_keymaps = {')
    end,
    write_entry = function(lines, entry)
      table.insert(lines, '    {')
      table.insert(lines, ('      mode = %q,'):format(entry.mode))
      table.insert(lines, ('      key = %q,'):format(entry.key))
      table.insert(lines, ('      desc = %q,'):format(entry.desc))
      table.insert(lines, '    },')
    end,
    write_footer = function(lines)
      table.insert(lines, '  },')
    end,
  },
}

local function source_section_by_name(name)
  for _, section in ipairs(source_sections) do
    if section.name == name then
      return section
    end
  end
  return nil
end

local function section_collect(collect_fn, source)
  if type(collect_fn) ~= 'function' then
    return {}
  end
  local ok, result = pcall(collect_fn, source)
  if not ok then
    return {}
  end
  return result or {}
end

local function format_source(sections)
  local lines = {
    '-- Generated conversion candidates from vim.fn.getcompletion(\'\', \'command\'), $VIMRUNTIME/doc/index.txt, and user keymaps.',
    'return {',
  }

  for _, section in ipairs(source_sections) do
    local entries = sections[section.name]
    if type(entries) == 'table' then
      section.write_header(lines)
      for _, entry in ipairs(entries) do
        section.write_entry(lines, entry)
      end
      section.write_footer(lines)
    end
  end

  table.insert(lines, '}')
  return lines
end

local function palette_commands(palette)
  if type(palette) ~= 'table' then
    return {}
  end

  if type(palette) == 'table' and type(palette.commands) == 'table' then
    return palette.commands
  end

  if palette[1] ~= nil then
    return palette
  end

  return {}
end

local function palette_builtin_keys(palette)
  if type(palette) == 'table' and type(palette.builtin_keys) == 'table' then
    return palette.builtin_keys
  end

  return {}
end

local function builtin_keys_by_command(builtin_keys)
  local result = {}
  local seen = {}
  for _, item in ipairs(builtin_keys) do
    if type(item) == 'table'
      and is_non_empty_string(item.source_command)
      and is_non_empty_string(item.mode)
      and is_non_empty_string(item.key)
    then
      local id = item.source_command .. '\t' .. item.mode .. '\t' .. item.key
      if not seen[id] then
        seen[id] = true
        result[item.source_command] = result[item.source_command] or {}
        table.insert(result[item.source_command], {
          mode = item.mode,
          key = item.key,
        })
      end
    end
  end
  return result
end

local function builtin_key_label(item)
  return ('%s %s'):format(mode_names[item.mode] or item.mode or '?', item.key or '')
end

local function builtin_key_aliases(item)
  local values = {
    item.tag,
    item.key,
    item.mode,
    item.source_command,
    item.description,
  }
  return vim.tbl_filter(is_non_empty_string, values)
end

local function builtin_key_item(item)
  local result = vim.deepcopy(item)
  result.kind = 'builtin_key'
  result.label = result.label or builtin_key_label(result)
  result.description = result.description or ''
  result.category = result.category or 'keymap'
  result.aliases = result.aliases or builtin_key_aliases(result)
  result.action = result.action or 'execute'
  result.keys = {
    {
      mode = result.mode,
      key = result.key,
    },
  }
  result.text = build_search_text(result)
  return result
end

local function choose_item(item)
  if item == nil then
    return
  end

  if item.kind == 'builtin_key' then
    vim.notify(('%s: %s'):format(item.label or item.key or '', item.description or ''), vim.log.levels.INFO)
    return
  end

  if item.action == 'execute' then
    vim.schedule(function()
      local ok, err = pcall(vim.cmd, item.command)
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end)
    return
  end

  local command_line = ':' .. item.command
  if not command_line:match('%s$') then
    command_line = command_line .. ' '
  end

  vim.schedule(function()
    local keys = vim.api.nvim_replace_termcodes(command_line, true, false, true)
    vim.api.nvim_feedkeys(keys, 'n', false)
  end)
end

function M.setup()
  pcall(vim.api.nvim_create_user_command, 'CommandPalette', function()
    M.open()
  end, { desc = '説明付きコマンドパレットを開く' })
end

function M.current_commands()
  return sorted_copy(vim.fn.getcompletion('', 'command'))
end

function M.current_source()
  local source = {}
  for _, section in ipairs(source_sections) do
    source[section.name] = section_collect(section.collect, source)
  end
  return source
end

function M.write_source_file(path)
  path = path or source_file_path()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  local source = M.current_source()
  vim.fn.writefile(format_source(source), path)
  return path
end

function M.coverage(opts)
  opts = opts or {}
  local source = read_source_file(opts.source_path)
  local palette = read_palette_file(opts.palette_path)

  local result = {
    sections = {},
    missing_label_count = 0,
    missing_description_count = 0,
    missing_category_count = 0,
    missing_aliases_count = 0,
    missing_action_count = 0,
    invalid_action_count = 0,
    missing_key_mode_count = 0,
    missing_key_value_count = 0,
  }

  for _, section in ipairs(source_sections) do
    local source_entries = source[section.name] or {}
    local palette_entries = palette[section.name] or {}

    -- Build lookup from source entries
    local source_lookup = {}
    for _, entry in ipairs(source_entries) do
      source_lookup[section.source_entry_id(entry)] = entry
    end

    local palette_lookup = {}
    local entry_counts = {}
    local section_missing = {}
    local section_extra = {}
    local section_duplicates = {}

    for _, entry in ipairs(palette_entries) do
      -- Required fields validation (shared across all section types)
      if type(entry) ~= 'table' then
        result.missing_label_count = result.missing_label_count + 1
        result.missing_description_count = result.missing_description_count + 1
        result.missing_category_count = result.missing_category_count + 1
        result.missing_aliases_count = result.missing_aliases_count + 1
        result.missing_action_count = result.missing_action_count + 1
      else
        if not is_non_empty_string(entry.label) then
          result.missing_label_count = result.missing_label_count + 1
        end
        if not is_non_empty_string(entry.description) then
          result.missing_description_count = result.missing_description_count + 1
        end
        if not is_non_empty_string(entry.category) then
          result.missing_category_count = result.missing_category_count + 1
        end
        if type(entry.aliases) ~= 'table' or #entry.aliases == 0 then
          result.missing_aliases_count = result.missing_aliases_count + 1
        end
        if not is_non_empty_string(entry.action) then
          result.missing_action_count = result.missing_action_count + 1
        elseif not valid_actions[entry.action] then
          result.invalid_action_count = result.invalid_action_count + 1
        end

        -- Key validation on entry.keys (primarily for commands section)
        if type(entry.keys) == 'table' then
          for _, key in ipairs(entry.keys) do
            if type(key) ~= 'table' or not is_non_empty_string(key.mode) then
              result.missing_key_mode_count = result.missing_key_mode_count + 1
            end
            if type(key) ~= 'table' or not is_non_empty_string(key.key) then
              result.missing_key_value_count = result.missing_key_value_count + 1
            end
          end
        end

        -- Key validation on entry itself (for builtin_keys, user_keymaps)
        if not is_non_empty_string(entry.mode) and is_non_empty_string(entry.key) then
          result.missing_key_mode_count = result.missing_key_mode_count + 1
        end
        if is_non_empty_string(entry.mode) and not is_non_empty_string(entry.key) then
          result.missing_key_value_count = result.missing_key_value_count + 1
        end
      end

      -- Match against source
      local id = section.palette_entry_id(entry)
      if id then
        entry_counts[id] = (entry_counts[id] or 0) + 1
        palette_lookup[id] = true
        if not source_lookup[id] then
          table.insert(section_extra, section.source_entry_label(entry))
        end
      end
    end

    -- Missing: in source but not in palette
    for id, src_entry in pairs(source_lookup) do
      if not palette_lookup[id] then
        table.insert(section_missing, section.source_entry_label(src_entry))
      end
    end

    -- Duplicates
    for id, count in pairs(entry_counts) do
      if count > 1 then
        table.insert(section_duplicates, id)
      end
    end

    table.sort(section_missing)
    table.sort(section_extra)
    table.sort(section_duplicates)

    result.sections[section.name] = {
      total = #source_entries,
      registered = #palette_entries,
      missing = section_missing,
      missing_count = #section_missing,
      extra = section_extra,
      extra_count = #section_extra,
      duplicates = section_duplicates,
      duplicate_count = #section_duplicates,
    }
  end

  result.ok = true
  for _, sr in pairs(result.sections) do
    if sr.missing_count > 0 or sr.extra_count > 0 or sr.duplicate_count > 0 then
      result.ok = false
      break
    end
  end
  if result.missing_label_count > 0
    or result.missing_description_count > 0
    or result.missing_category_count > 0
    or result.missing_aliases_count > 0
    or result.missing_action_count > 0
    or result.invalid_action_count > 0
    or result.missing_key_mode_count > 0
    or result.missing_key_value_count > 0
  then
    result.ok = false
  end

  return result
end

local function append_detail(lines, title, values)
  if #values == 0 then
    return
  end

  local limit = math.min(#values, 50)
  table.insert(lines, ('%s: %s'):format(title, table.concat(vim.list_slice(values, 1, limit), ', ')))
  if #values > limit then
    table.insert(lines, ('%s 残り: %d'):format(title, #values - limit))
  end
end

function M.coverage_lines()
  local result = M.coverage()
  local lines = { '== カバレッジ ==' }

  for _, section in ipairs(source_sections) do
    local sr = result.sections[section.name]
    if sr then
      table.insert(lines, ('  %s'):format(section.label))
      table.insert(lines, ('    変換候補数: %d'):format(sr.total))
      table.insert(lines, ('    登録数: %d'):format(sr.registered))
      table.insert(lines, ('    未登録数: %d'):format(sr.missing_count))
      table.insert(lines, ('    余剰登録数: %d'):format(sr.extra_count))
    end
  end

  table.insert(lines, '')
  table.insert(lines, '== 検証 ==')
  table.insert(lines, ('label 欠落数: %d'):format(result.missing_label_count))
  table.insert(lines, ('description 欠落数: %d'):format(result.missing_description_count))
  table.insert(lines, ('category 欠落数: %d'):format(result.missing_category_count))
  table.insert(lines, ('aliases 欠落数: %d'):format(result.missing_aliases_count))
  table.insert(lines, ('action 欠落数: %d'):format(result.missing_action_count))
  table.insert(lines, ('action 不正数: %d'):format(result.invalid_action_count))
  table.insert(lines, ('key mode 欠落数: %d'):format(result.missing_key_mode_count))
  table.insert(lines, ('key 欠落数: %d'):format(result.missing_key_value_count))

  local detail_lines = {}
  for _, section in ipairs(source_sections) do
    local sr = result.sections[section.name]
    if sr then
      append_detail(detail_lines, ('未登録: %s'):format(section.label), sr.missing)
      append_detail(detail_lines, ('余剰登録: %s'):format(section.label), sr.extra)
      append_detail(detail_lines, ('重複: %s'):format(section.label), sr.duplicates)
    end
  end

  if #detail_lines > 0 then
    table.insert(lines, '')
    table.insert(lines, '== 詳細 ==')
    vim.list_extend(lines, detail_lines)
  end

  return lines, result.ok
end

function M.print_coverage()
  local lines, ok = M.coverage_lines()
  for _, line in ipairs(lines) do
    print(line)
  end
  return ok
end

local command_palette_filters = {
  {
    label = 'Ex',
    match = function(item) return item.kind ~= 'builtin_key' end,
  },
  {
    label = 'N',
    mode = 'n',
  },
  {
    label = 'V',
    mode = 'x',
  },
  {
    label = 'I',
    mode = 'i',
  },
  {
    label = 'C',
    mode = 'c',
  },
  {
    label = 'O',
    mode = 'o',
  },
  {
    label = '全件',
    match = function() return true end,
  },
}

local function item_has_mode(item, mode)
  if item.mode == mode then
    return true
  end

  if type(item.keys) ~= 'table' then
    return false
  end

  for _, key in ipairs(item.keys) do
    if key.mode == mode then
      return true
    end
  end

  return false
end

local function filter_items(items, filter)
  if filter.mode ~= nil then
    return vim.tbl_filter(function(item) return item_has_mode(item, filter.mode) end, items)
  end

  return vim.tbl_filter(filter.match, items)
end

local function match_query_text(query)
  local text = vim.trim(table.concat(query or {}))
  text = text:gsub("^['*^]", '')
  text = text:gsub('%$$', '')
  return vim.trim(text:lower())
end

local function match_query_variants(query)
  if query == '' then
    return {}
  end

  local variants = { query }
  vim.list_extend(variants, search_query_variants[query] or {})
  return variants
end

local function search_value_score(value, variants, weight)
  if not is_non_empty_string(value) then
    return nil
  end

  local text = value:lower()
  local best = nil
  for _, query in ipairs(variants) do
    local start_col = text:find(query:lower(), 1, true)
    if start_col ~= nil then
      local score = weight + start_col
      if text == query then
        score = weight - 20
      elseif vim.startswith(text, query) then
        score = weight
      end
      best = best == nil and score or math.min(best, score)
    end
  end

  return best
end

local function item_search_score(item, query)
  local variants = match_query_variants(query)
  if #variants == 0 then
    return item_priority(item)
  end

  local fields = item.search_fields or {}
  local best = nil
  for _, name in ipairs(search_field_order) do
    local weight = search_field_weight[name] or 200
    for _, value in ipairs(fields[name] or {}) do
      local score = search_value_score(value, variants, weight)
      if score ~= nil then
        best = best == nil and score or math.min(best, score)
      end
    end
  end

  return best or 10000 + item_priority(item)
end

local function weighted_matcher(pick, items_for_match)
  return function(stritems, inds, query)
    local match_inds = pick.default_match(stritems, inds, query, { sync = true })
    if match_inds == nil or #query == 0 then
      return match_inds
    end

    local query_text = match_query_text(query)
    if query_text == '' then
      return match_inds
    end

    local items = items_for_match()
    local default_rank = {}
    for rank, index in ipairs(match_inds) do
      default_rank[index] = rank
    end

    table.sort(match_inds, function(left, right)
      local left_score = item_search_score(items[left] or {}, query_text)
      local right_score = item_search_score(items[right] or {}, query_text)
      if left_score ~= right_score then
        return left_score < right_score
      end
      return (default_rank[left] or left) < (default_rank[right] or right)
    end)

    return match_inds
  end
end

function M.open()
  local ok, pick = pcall(require, 'mini.pick')
  if not ok then
    vim.notify('mini.pick を読み込めないため、コマンドパレットを開けません', vim.log.levels.ERROR)
    return
  end

  local palette_ok, palette = pcall(read_palette_file)
  if not palette_ok then
    vim.notify(('command_palette.lua を読み込めません: %s'):format(palette), vim.log.levels.ERROR)
    return
  end

  local entries = palette_commands(palette)
  local builtin_keys = palette_builtin_keys(palette)
  if #entries == 0 and #builtin_keys == 0 then
    vim.notify('command_palette.lua に登録項目がありません。候補一覧とカバレッジを確認して辞書を埋めてください', vim.log.levels.WARN)
    return
  end

  local keys_by_command = keymap_index(entries)
  local builtin_keys_for_command = builtin_keys_by_command(builtin_keys)
  local items = vim.tbl_map(function(entry)
    local item = vim.deepcopy(entry)
    item.keys = merge_keys(entry.keys, builtin_keys_for_command[entry.command], keys_by_command[entry.command])
    item.text = build_search_text(item)
    return item
  end, entries)
  for _, item in ipairs(builtin_keys) do
    table.insert(items, builtin_key_item(item))
  end
  sort_items(items)

  local filter_index = #command_palette_filters
  local active_items
  local function current_filter()
    return command_palette_filters[filter_index]
  end
  local function current_items()
    return filter_items(items, current_filter())
  end
  local function current_name()
    local filtered = current_items()
    return ('Command Palette [%s] %d/%d  Tab:切替'):format(current_filter().label, #filtered, #items)
  end
  local function cycle_filter(delta)
    filter_index = ((filter_index - 1 + delta) % #command_palette_filters) + 1
    active_items = current_items()
    pick.set_picker_opts({ source = { name = current_name() } })
    pick.set_picker_items(active_items, { do_match = true })
  end

  active_items = current_items()

  pick.start({
    mappings = {
      toggle_preview = '',
      next_filter = {
        char = '<Tab>',
        func = function()
          cycle_filter(1)
        end,
      },
      previous_filter = {
        char = '<S-Tab>',
        func = function()
          cycle_filter(-1)
        end,
      },
    },
    source = {
      items = active_items,
      name = current_name(),
      match = weighted_matcher(pick, function() return active_items end),
      show = show_items,
      choose = choose_item,
    },
    window = {
      config = function()
        local height = math.floor(0.72 * vim.o.lines)
        local width = math.floor(0.88 * vim.o.columns)
        return {
          anchor = 'NW',
          height = height,
          width = width,
          row = math.floor(0.5 * (vim.o.lines - height)),
          col = math.floor(0.5 * (vim.o.columns - width)),
        }
      end,
    },
  })
end

return M
