local null_present, null_ls = pcall(require, "null-ls")
if not null_present then
	vim.notify("null-ls couldn't be loaded", "error", {
		title = "jose-elias-alvarez/null-ls",
	})
	return
end

null_ls.setup({
	sources = {
		null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.diagnostics.stylelint,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.autopep8,
		null_ls.builtins.formatting.dart_format,
		null_ls.builtins.formatting.eslint_d,
		null_ls.builtins.formatting.gofmt,
	},
})
