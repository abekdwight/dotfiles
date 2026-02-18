vim.o.background = 'dark'

local ok = pcall(vim.cmd, 'colorscheme dracula')
if not ok then
  vim.cmd('colorscheme default')
end

-- Diff のハイライトを薄くしてシンタックスハイライトを見やすくする
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#2a4a2a' })
vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#4a2a2a' })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2a2a4a' })
vim.api.nvim_set_hl(0, 'DiffText', { bg = '#4a4a2a' })
