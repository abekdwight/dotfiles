vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function(args)
    local ok, formatter = pcall(require, 'config.formatting')
    if not ok then
      return
    end
    formatter.format(args.buf)
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
