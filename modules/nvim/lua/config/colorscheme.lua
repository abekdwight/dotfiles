vim.o.background = 'dark'

-- FloatBorder の前景色が背景と同化して不可視になるため上書き
-- darkplus border (#2d2d2d) → #c0c0c0（fg に近い明度）で視認性を確保
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'darkplus',
  callback = function()
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#c0c0c0', bg = '#1e1e1e' })
    vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#c0c0c0', bg = '#1e1e1e', bold = true })
  end,
})

local ok = pcall(vim.cmd, 'colorscheme darkplus')
if not ok then
  vim.cmd('colorscheme default')
end

-- colorscheme 読み込み直後にも直接設定（autocmd が期待通り発火しない場合の安全策）
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#c0c0c0', bg = '#1e1e1e' })
vim.api.nvim_set_hl(0, 'FloatTitle', { fg = '#c0c0c0', bg = '#1e1e1e', bold = true })
