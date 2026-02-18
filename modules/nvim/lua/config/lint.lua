local lint = require('lint')

local function has(cmd)
  return vim.fn.executable(cmd) == 1
end

local eslint = {}
if has('eslint_d') then
  table.insert(eslint, 'eslint_d')
elseif has('eslint') then
  table.insert(eslint, 'eslint')
end

local go_linters = {}
if has('golangci-lint') then
  table.insert(go_linters, 'golangcilint')
end
if has('revive') then
  table.insert(go_linters, 'revive')
end

local rust_linters = {}
if has('cargo') then
  table.insert(rust_linters, 'clippy')
end

lint.linters_by_ft = {
  javascript = eslint,
  javascriptreact = eslint,
  typescript = eslint,
  typescriptreact = eslint,
  go = go_linters,
  rust = rust_linters,
}

local group = vim.api.nvim_create_augroup('Linting', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
  group = group,
  callback = function()
    lint.try_lint()
  end,
})
