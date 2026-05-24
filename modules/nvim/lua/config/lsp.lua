local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')

mason.setup()

local servers = {
  'ts_ls',
  'eslint',
  'gopls',
  'rust_analyzer',
  'intelephense',
  'solargraph',
  'html',
  'cssls',
  'bashls',
  'emmet_ls',
}

mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_enable = false,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local has_new_api = vim.lsp and vim.lsp.config and vim.lsp.enable

if has_new_api then
  for _, server in ipairs(servers) do
    vim.lsp.config(server, {
      capabilities = capabilities,
    })
  end

  for _, server in ipairs(servers) do
    vim.lsp.enable(server)
  end
else
  local lspconfig = require('lspconfig')
  local legacy_servers = vim.deepcopy(servers)

  if not lspconfig.ts_ls then
    for i, name in ipairs(legacy_servers) do
      if name == 'ts_ls' then
        legacy_servers[i] = 'tsserver'
        break
      end
    end
  end

  for _, server in ipairs(legacy_servers) do
    if lspconfig[server] and type(lspconfig[server].setup) == 'function' then
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- K で hover 時に border を直接指定（handler 設定が効かない場合の安全策）
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover({ border = 'rounded' })
    end, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})
