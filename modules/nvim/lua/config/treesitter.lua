require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'lua',
    'vimdoc',
    'vim',
    'query',
    'regex',
    'markdown',
    'markdown_inline',
    'javascript',
    'typescript',
    'tsx',
    'go',
    'rust',
    'php',
    'phpdoc',
    'blade',
    'ruby',
    'json',
    'html',
    'css',
    'yaml',
    'toml',
    'bash',
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = function(_, buf)
      local max_filesize = 100 * 1024
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      return false
    end,
  },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      node_incremental = '<CR>',
      node_decremental = '<BS>',
      scope_incremental = false,
    },
  },
  auto_install = true,
})
