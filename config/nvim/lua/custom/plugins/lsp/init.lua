
local km = vim.keymap.set
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
km("n", '[d', vim.diagnostic.goto_prev, opts)
km("n", ']d', vim.diagnostic.goto_next, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  km("n", "gD", vim.lsp.buf.declaration, bufopts)
  km("n", "gd", vim.lsp.buf.definition, bufopts)
  km("n", "K", vim.lsp.buf.hover, bufopts)
  km("n", "gi", vim.lsp.buf.implementation, bufopts)
  km("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  km("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  km("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  km("n", "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  km("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
  km("n", "<space>rn", vim.lsp.buf.rename, bufopts)
  km("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
  km("n", "gr", vim.lsp.buf.references, bufopts)
  km("n", "<space>lf", function()
    vim.lsp.buf.format({
      -- filter = function(clnt) return clnt.name ~= "tsserver" end,
      async = true
    })
  end, bufopts)
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
