vim.g.undotree_WindowLayout = 3
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_folding_disabled = 1
vim.g.table_mode_corner = '|'
vim.g.rustaceanvim = {}

local function safe_require(name)
  local ok, mod = pcall(require, name)
  if ok then
    return mod
  end
  return nil
end

local colorizer = safe_require('colorizer')
if colorizer then
  colorizer.setup({ '*'}, {
    css = true,
    css_fn = true,
    mode = 'background',
  })
end

local autotag = safe_require('nvim-ts-autotag')
if autotag then
  autotag.setup()
end

local diffview = safe_require('diffview')
if diffview then
  local actions = require('diffview.actions')
  diffview.setup({
    enhanced_diff_hl = true,
    file_panel = {
      listing_style = 'tree',
      tree_options = {
        flatten_dirs = true,
        folder_statuses = 'only_folded',
      },
    },
    keymaps = {
      file_panel = {
        ['j'] = actions.select_next_entry,
        ['k'] = actions.select_prev_entry,
        ['<C-d>'] = actions.scroll_view(10),
        ['<C-u>'] = actions.scroll_view(-10),
        ['u'] = actions.toggle_stage_entry,
      },
    },
  })
end

local neogit = safe_require('neogit')
if neogit then
  neogit.setup({
    integrations = {
      diffview = true,
    },
  })
end

local trouble = safe_require('trouble')
if trouble then
  trouble.setup({
    auto_close = false,
    auto_open = false,
    use_diagnostic_signs = true,
  })
end

-- vim-visual-multi: multi-cursor editing (default: Ctrl+n)
vim.g.VM_silent_exit = 1

local aerial = safe_require('aerial')
if aerial then
  aerial.setup({
    backends = { 'lsp', 'treesitter' },
    layout = {
      default_direction = 'right',
      placement = 'edge',
    },
    keymaps = {
      ['<Esc>'] = 'actions.close',
    },
  })
end

-- Goyo (zen mode)
vim.g.goyo_width = 160
vim.g.goyo_height = '100%'

vim.api.nvim_create_autocmd('User', {
  pattern = 'GoyoEnter',
  callback = function()
    vim.opt.number = true
    vim.opt.relativenumber = true
  end,
})

vim.keymap.set('n', '<leader>z', ':Goyo<CR>', { desc = 'Toggle zen mode (Goyo)' })
