local function km(mode, lhs, rhs, desc, bufnr)
  local options = { noremap=true, silent=true, desc=desc }
  if bufnr then
    options.buffer = bufnr
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Global Diagnostic Mappings
km("n", '[d', vim.diagnostic.goto_prev, "Previous Diagnostic")
km("n", ']d', vim.diagnostic.goto_next, "Next Diagnostic")
km("n", 'gl', vim.diagnostic.open_float, "Show Line Diagnostics")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- LSP Mappings
  km("n", "gD", vim.lsp.buf.declaration, "Go to Declaration", bufnr)
  km("n", "gd", vim.lsp.buf.definition, "Go to Definition", bufnr)
  km("n", "K", vim.lsp.buf.hover, "Hover Documentation", bufnr)
  km("n", "gi", vim.lsp.buf.implementation, "Go to Implementation", bufnr)
  km("n", "gK", vim.lsp.buf.signature_help, "Signature Help", bufnr)
  km("n", "<space>D", vim.lsp.buf.type_definition, "Type Definition", bufnr)
  km("n", "<space>rn", vim.lsp.buf.rename, "Rename Symbol", bufnr)
  km("n", "<space>ca", vim.lsp.buf.code_action, "Code Action", bufnr)
  km("n", "gr", vim.lsp.buf.references, "Find References", bufnr)
  km("n", "<space>lf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format Document", bufnr)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- blink.cmp supports LSP capabilities, so advertise it to LSP servers
local capabilities = require('blink.cmp').get_lsp_capabilities()

local function setup_server(name, opts)
  if vim.lsp.config then
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
  else
    require("lspconfig")[name].setup(opts)
  end
end

-- Setup native CDS LSP
setup_server("cds", {
  cmd = { vim.fn.has("win32") == 1 and "cmd.exe" or "cds-lsp", vim.fn.has("win32") == 1 and "/C" or "--stdio" },
  filetypes = { "cds" },
  root_markers = { ".cdsrc.json", "package.json", ".git" },
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
})

setup_server("ts_ls", { on_attach = on_attach, flags = lsp_flags, capabilities = capabilities })

setup_server("rust_analyzer", {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  settings = { ["rust-analyzer"] = {} }
})

setup_server("lua_ls", {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = {'vim'} },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
