local treesitter = require('nvim-treesitter')

local languages = {
  'bash',
  'blade',
  'css',
  'go',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'php',
  'phpdoc',
  'query',
  'regex',
  'ruby',
  'rust',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

local filetypes = {
  'bash',
  'blade',
  'css',
  'go',
  'help',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'lua',
  'markdown',
  'php',
  'query',
  'ruby',
  'rust',
  'sh',
  'toml',
  'typescript',
  'typescriptreact',
  'vim',
  'vimdoc',
  'yaml',
  'zsh',
}

treesitter.setup()

vim.treesitter.language.register('bash', { 'sh', 'zsh' })
vim.treesitter.language.register('javascript', 'javascriptreact')
vim.treesitter.language.register('tsx', 'typescriptreact')
vim.treesitter.language.register('vimdoc', 'help')

treesitter.install(languages)

local max_filesize = 100 * 1024

local function is_small_enough(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if path == '' then
    return true
  end

  local ok, stats = pcall(vim.uv.fs_stat, path)
  return not (ok and stats and stats.size > max_filesize)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function(args)
    if not is_small_enough(args.buf) then
      return
    end

    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      return
    end

    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
