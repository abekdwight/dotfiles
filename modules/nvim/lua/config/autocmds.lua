vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    local ok, formatter = pcall(require, 'config.formatting')
    if not ok then
      return
    end
    formatter.format(args.buf)
  end,
})

local function sync_wrap_for_window(win_id)
  vim.wo[win_id].wrap = not vim.wo[win_id].diff
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  callback = function(args)
    local win_id = vim.fn.bufwinid(args.buf)
    if win_id ~= -1 then
      sync_wrap_for_window(win_id)
      return
    end
    sync_wrap_for_window(vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'diff',
  callback = function()
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
      sync_wrap_for_window(win_id)
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local cwd = vim.fn.getcwd()
    local git_root

    if vim.fs and vim.fs.find then
      local git_dir = vim.fs.find('.git', { upward = true, path = cwd })[1]
      if git_dir then
        git_root = vim.fs.dirname(git_dir)
      end
    else
      local git_dir = vim.fn.finddir('.git', cwd .. ';')
      if git_dir ~= '' then
        git_root = vim.fn.fnamemodify(git_dir, ':h')
      end
    end

    if git_root and git_root ~= '' and git_root ~= cwd then
      vim.fn.chdir(git_root)
    end
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  callback = function()
    vim.fn.system({ 'im-select', 'com.apple.keylayout.USBasic' })
  end,
  desc = 'インサートモードからノーマルモードへ戻った際にIMEを英数に切り替え'
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(args)
    local buf_id = args.data and args.data.buf_id
    if not buf_id then
      return
    end

    local mini_files = require('mini.files')

    local function at_anchor()
      local state = mini_files.get_explorer_state()
      if not state then
        return false
      end
      local focused = state.branch[state.depth_focus]
      return focused == state.anchor
    end

    local function go_out()
      if at_anchor() then
        return
      end
      mini_files.go_out()
    end

    local function go_out_plus()
      if at_anchor() then
        return
      end
      mini_files.go_out()
      mini_files.trim_right()
    end

    vim.keymap.set('n', 'h', go_out, { buffer = buf_id, desc = '親ディレクトリへ' })
    vim.keymap.set('n', 'H', go_out_plus, { buffer = buf_id, desc = '親へ移動して右をトリム' })
  end,
})
