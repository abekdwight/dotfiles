local M = {}

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, conform = pcall(require, 'conform')
  if ok then
    conform.format({
      bufnr = bufnr,
      lsp_format = 'fallback',
      timeout_ms = 1000,
    })
    return
  end

  if vim.lsp and vim.lsp.buf and vim.lsp.buf.format then
    vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
  end
end

local function setup()
  local ok, conform = pcall(require, 'conform')
  if not ok then
    return
  end

  conform.setup({
    formatters_by_ft = {
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      go = { 'goimports', 'gofmt' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
    },
    default_format_opts = {
      lsp_format = 'fallback',
    },
  })
end

setup()

return M
