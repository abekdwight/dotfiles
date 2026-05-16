local map = vim.keymap.set
local jump2d = require('mini.jump2d')
local command_palette = require('config.command_palette_core')

command_palette.setup()

map('n', '<Esc><Esc>', '<cmd>nohlsearch<cr><esc>', { desc = '検索ハイライト解除' })
map('n', '<leader>w', function()
  jump2d.start(jump2d.builtin_opts.word_start)
end, { desc = 'ジャンプ(単語先頭)' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = '終了' })
map('n', '<leader>f', function()
  require('config.formatting').format()
end, { desc = 'フォーマット' })
map('n', '<leader>ll', function()
  require('lint').try_lint()
end, { desc = 'Lint実行' })

map('n', '<Tab>', '<cmd>bnext<cr>', { desc = '次のバッファ', silent = true })
map('n', '<S-Tab>', '<cmd>bprevious<cr>', { desc = '前のバッファ', silent = true })

map('n', '<leader>ff', function()
  require('mini.pick').builtin.files({ tool = 'git' })
end, { desc = 'ファイル検索(Git)' })
map('n', '<leader>fo', function()
  require('mini.pick').builtin.buf_lines()
end, { desc = 'バッファ内検索' })
map('n', '<leader>fg', function()
  require('mini.pick').builtin.grep_live()
end, { desc = '全文検索' })
map('n', '<leader>fb', function()
  require('mini.pick').builtin.buffers()
end, { desc = 'バッファ一覧' })
map('n', '<leader>fh', function()
  require('mini.pick').builtin.help()
end, { desc = 'ヘルプ検索' })
map('n', '<leader>fr', function()
  require('mini.extra').pickers.registers()
end, { desc = 'レジスタ検索' })
map('n', '<leader>ft', function()
  require('mini.pick').builtin.grep_live({ pattern = 'TODO|FIXME|HACK|NOTE' })
end, { desc = 'TODO検索' })
map('n', '<leader>p', '<cmd>CommandPalette<cr>', { desc = 'コマンドパレット' })
map('n', '<leader>/', function()
  require('mini.pick').builtin.resume()
end, { desc = '前回の検索を再開' })

map('n', '<leader>e', function()
  jump2d.start(jump2d.builtin_opts.word_end)
end, { desc = 'ジャンプ(単語末尾)' })
map('n', '<leader>fe', function()
  local mini_files = require('mini.files')
  local uv = vim.uv or vim.loop
  local path = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  local start_path = cwd

  if path ~= '' then
    start_path = vim.fs.normalize(vim.fs.dirname(path))
  end

  local git_dirs = vim.fs.find('.git', { upward = true, path = start_path, limit = 1 })
  local root = cwd
  if #git_dirs > 0 then
    root = vim.fs.normalize(vim.fs.dirname(git_dirs[1]))
  end

  mini_files.open(root, false)

  if path == '' then
    return
  end

  local normalized_path = vim.fs.normalize(path)
  local path_stat = uv.fs_stat(normalized_path)
  local target = normalized_path

  if not path_stat then
    target = vim.fs.normalize(vim.fs.dirname(normalized_path))
  end

  local stack = {}
  local cursor = target
  while true do
    table.insert(stack, cursor)
    if cursor == root then
      break
    end

    local parent = vim.fs.normalize(vim.fs.dirname(cursor))
    if parent == cursor then
      return
    end
    cursor = parent
  end

  local branch = {}
  for i = #stack, 1, -1 do
    local branch_path = stack[i]
    if uv.fs_stat(branch_path) then
      table.insert(branch, branch_path)
    end
  end

  if #branch > 0 then
    mini_files.set_branch(branch)
  end
end, { desc = 'ファイラ(プロジェクト)', silent = true })
map('n', '<leader>-e', function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    require('mini.files').open(vim.fn.getcwd(), true)
    return
  end
  require('mini.files').open(vim.fs.dirname(path), true)
end, { desc = 'ファイラ(現在ファイルのディレクトリ)', silent = true })
map('n', '<leader>E', function()
  require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = 'ファイラ(現在ファイル)', silent = true })

map('n', '<leader>ha', function()
  require('mini.visits').add_label('harpoon')
end, { desc = 'Harpoon: 追加' })
map('n', '<leader>hh', function()
  require('mini.extra').pickers.visit_labels({ filter = 'harpoon' })
end, { desc = 'Harpoon: 一覧' })
map('n', '<leader>hr', function()
  require('mini.visits').remove_label('harpoon')
end, { desc = 'Harpoon: 削除' })

for i = 1, 4 do
  map('n', '<leader>' .. i, function()
    local visits = require('mini.visits')
    if i == 1 then
      visits.iterate_paths('first', nil, { filter = 'harpoon' })
      return
    end
    visits.iterate_paths('forward', nil, { filter = 'harpoon', n_times = i, wrap = false })
  end, { desc = ('Harpoon: %d番目へ'):format(i) })
end

map('n', '<leader>ss', function()
  require('mini.sessions').write()
end, { desc = 'セッション保存', silent = true })
map('n', '<leader>sl', function()
  require('mini.sessions').select()
end, { desc = 'セッション読込', silent = true })
map('n', '<leader>sd', function()
  require('mini.sessions').delete()
end, { desc = 'セッション削除', silent = true })

map('n', '<leader>mm', function()
  require('mini.map').toggle()
end, { desc = 'ミニマップ切替', silent = true })
map('n', '<leader>mf', function()
  require('mini.map').toggle_focus()
end, { desc = 'ミニマップフォーカス', silent = true })
map('n', '<leader>mr', function()
  require('mini.map').refresh()
end, { desc = 'ミニマップ更新', silent = true })

map('n', '<leader>bc', function()
  require('mini.bufremove').delete()
end, { desc = 'バッファを閉じる', silent = true })
map('n', '<leader>bbc', '<cmd>%bd<cr>', { desc = '全バッファを閉じる', silent = true })
map('n', '<leader>tw', function()
  require('mini.trailspace').trim()
end, { desc = '末尾空白を削除', silent = true })
map('n', '<leader>z', function()
  require('mini.misc').zoom()
end, { desc = 'ウィンドウズーム', silent = true })

map('n', ']h', function()
  require('mini.diff').goto_hunk('next')
end, { desc = '次の差分', silent = true })
map('n', '[h', function()
  require('mini.diff').goto_hunk('prev')
end, { desc = '前の差分', silent = true })
map('n', '<leader>go', function()
  require('mini.diff').toggle_overlay()
end, { desc = '差分オーバーレイ', silent = true })

map('n', '<leader>gg', '<cmd>Neogit<cr>', { desc = 'Neogit' })
map('n', '<leader>gd', function()
  local lib = require('diffview.lib')
  if lib.get_current_view() then
    vim.cmd('DiffviewClose')
  else
    vim.cmd('DiffviewOpen')
  end
end, { desc = 'Diffview toggle' })
map('n', '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'ファイル履歴' })

map('n', '<leader>dd', '<cmd>Trouble diagnostics toggle<cr>', { desc = '診断一覧' })
map('n', '<leader>a', '<cmd>AerialToggle<cr>', { desc = 'シンボル一覧' })
map('n', '<leader>u', '<cmd>UndotreeToggle | UndotreeFocus<cr>', { desc = 'Undoツリー' })

map('n', '[d', vim.diagnostic.goto_prev, { desc = '前の診断' })
map('n', ']d', vim.diagnostic.goto_next, { desc = '次の診断' })
map('n', '<leader>df', vim.diagnostic.open_float, { desc = '診断を表示' })
map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = '診断リスト' })
