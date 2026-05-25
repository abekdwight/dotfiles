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
  local jump2d = require('mini.jump2d')
  jump2d.start({ spotter = jump2d.gen_spotter.pattern('[^%s%p]+', 'end') })
end, { desc = 'ジャンプ(単語末尾)' })
map('n', '<leader>fe', function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.cmd('Neotree toggle')
    return
  end
  local git_dirs = vim.fs.find('.git', { upward = true, path = vim.fs.dirname(path), limit = 1 })
  if #git_dirs > 0 then
    vim.cmd('Neotree toggle dir=' .. vim.fn.fnameescape(vim.fs.dirname(git_dirs[1])))
  else
    vim.cmd('Neotree toggle')
  end
end, { desc = 'ファイラ(プロジェクト)', silent = true })
map('n', '<leader>-e', function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then
    vim.cmd('Neotree toggle')
    return
  end
  vim.cmd('Neotree toggle dir=' .. vim.fn.fnameescape(vim.fs.dirname(path)))
end, { desc = 'ファイラ(現在ファイルのディレクトリ)', silent = true })
map('n', '<leader>E', function()
  vim.cmd('Neotree reveal')
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

local function split_japanese_sentences()
  local mode = vim.fn.mode()
  local start_line, end_line

  if mode == 'v' or mode == 'V' then
    start_line = vim.fn.line("'<")
    end_line = vim.fn.line("'>")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  else
    start_line = 1
    end_line = vim.fn.line('$')
  end

  -- 下から上に処理（行番号がずれるのを防ぐ）
  for line = end_line, start_line, -1 do
    local content = vim.fn.getline(line)
    -- 「。」の直後が「。」または改行でなければ改行を挿入（三点リーダーを保護）
    local new_content = vim.fn.substitute(content, '。\\([^。\\n]\\)', '。\n\\1', 'g')
    if new_content ~= content then
      local parts = vim.split(new_content, '\n', { plain = true })
      vim.fn.setline(line, parts[1])
      for i = 2, #parts do
        vim.fn.append(line + i - 2, parts[i])
      end
    end
  end
end

map('n', '<leader>js', split_japanese_sentences, { desc = '「。」で改行分割' })
map('v', '<leader>js', split_japanese_sentences, { desc = '「。」で改行分割' })

map('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  if path == '' then return vim.notify('No file', vim.log.levels.WARN) end
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO, { title = 'Absolute path' })
end, { desc = '絶対パスをコピー' })
map('n', '<leader>yr', function()
  local path = vim.fn.expand('%')
  if path == '' then return vim.notify('No file', vim.log.levels.WARN) end
  vim.fn.setreg('+', path)
  vim.notify(path, vim.log.levels.INFO, { title = 'Relative path' })
end, { desc = '相対パスをコピー' })
