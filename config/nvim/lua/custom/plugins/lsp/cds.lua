local cfg_present, configs = pcall(require, "lspconfig.configs")
if not cfg_present then
	vim.notify("LSP config couldn't be loaded", "error", {
		title = "lspconfig/configs",
	})
end
local util_present, util = pcall(require, "lspconfig/util")
if not util_present then
	vim.notify("LSP config couldn't be loaded", "error", {
		title = "lspconfig/util",
	})
end

local bin_name = "cds-lsp"
local cmd = { bin_name, "--stdio" }

if vim.fn.has("win32") == 1 then
	cmd = { "cmd.exe", "/C", bin_name, "--stdio" }
end

if not configs["cds"] then
	configs["cds"] = {
		default_config = {
			cmd = cmd,
			filetypes = { "cds" },
			root_dir = function(fname)
				return util.root_pattern(".cdsrc.json")(fname)
					or util.root_pattern("package.json", ".git")(fname)
			end,
		},
	}
end
