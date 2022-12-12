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
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", 'v:lua.vim.lsp.omnifunc')

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

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- TODO: Each server config should be configured via. loop instead of long list of file
local lspcfg_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspcfg_status_ok then
  vim.notify("lspconfig couldn't be loaded", "error", {
    title = "neovim/nvim-lspconfig"
  })
  return
end
lspconfig["pyright"].setup({
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities
})
lspconfig["tsserver"].setup({
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities
})
lspconfig["rust_analyzer"].setup({
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
})
lspconfig["sumneko_lua"].setup({
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities,
  -- server - specific settings
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})
