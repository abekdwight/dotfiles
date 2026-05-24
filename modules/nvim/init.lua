vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.diagnostics')
require('config.autocmds')

local path_package = vim.fn.stdpath('data') .. '/site'
local mini_path = path_package .. '/pack/deps/start/mini.nvim'

if not vim.loop.fs_stat(mini_path) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  })
end

vim.opt.rtp:prepend(mini_path)

require('mini.deps').setup({
  path = { package = path_package },
})

local add, now = MiniDeps.add, MiniDeps.now

add({ source = 'echasnovski/mini.nvim' })
add({
  source = 'nvim-treesitter/nvim-treesitter',
  checkout = 'master',
  monitor = 'main',
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})
add({ source = 'nvim-treesitter/nvim-treesitter-textobjects' })

add({ source = 'neovim/nvim-lspconfig' })
add({ source = 'williamboman/mason.nvim' })
add({ source = 'williamboman/mason-lspconfig.nvim' })
add({ source = 'stevearc/conform.nvim' })
add({ source = 'mfussenegger/nvim-lint' })

add({ source = 'folke/trouble.nvim' })
add({ source = 'stevearc/aerial.nvim' })
add({ source = 'mbbill/undotree' })
add({ source = 'HiPhish/rainbow-delimiters.nvim' })
add({ source = 'NvChad/nvim-colorizer.lua' })
add({ source = 'windwp/nvim-ts-autotag' })
add({ source = 'mrcjkb/rustaceanvim' })
add({ source = 'gpanders/editorconfig.nvim' })
add({ source = 'dhruvasagar/vim-table-mode' })
add({ source = 'kana/vim-textobj-user' })
add({ source = 'kana/vim-textobj-entire' })
add({ source = 'preservim/vim-markdown' })
add({ source = 'junegunn/goyo.vim' })
add({ source = 'LunarVim/darkplus.nvim' })
add({ source = 'mg979/vim-visual-multi' })

add({
  source = 'NeogitOrg/neogit',
  depends = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
  },
})
add({ source = 'nvim-lua/plenary.nvim' })
add({ source = 'sindrets/diffview.nvim' })

now(function() require('config.mini') end)
now(function() require('config.minifiles-git') end)
now(function() require('config.colorscheme') end)
now(function() require('config.treesitter') end)
now(function() require('config.lsp') end)
now(function() require('config.extras') end)
now(function() require('config.formatting') end)
now(function() require('config.lint') end)
