local dap_present, dap = pcall(require, "dap")
if not dap_present then
	vim.notify("dap couldn't be loaded", "error", {
		title = "mfussenegger/nvim-dap",
	})
	return
end

local km = vim.keymap.set
local opts = { silent = true, noremap = true }

-- DAP debugging suggested keymapping - Check if nvim-dap-ui sets these
km("n", "<F5>", "<cmd>lua require('dap').continue()<CR>", opts)
km("n", "<C-\\>", "<cmd>lua require('dap').continue()<CR>", opts)
km("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>", opts)
km("n", "<C-'>", "<cmd>lua require('dap').step_over()<CR>", opts)
km("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>", opts)
km("n", "<C-;>", "<cmd>lua require('dap').step_into()<CR>", opts)
km("n", "<F12>", "<cmd>lua require('dap').step_out()<CR>", opts)
km("n", "<C-/>", "<cmd>lua require('dap').step_out()<CR>", opts)
km("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)
km("n", "<leader>B", "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts)
km("n", "<leader>lp", "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", opts)
km("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>", opts)
km("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>", opts)

-- sign configuration for DAP, Possible Values: DapBreakpoint, DapBreakpointCondition, DapLogPoint, DapStopped, DapBreakpointRejected

vim.api.nvim_set_hl(0, "DapBreakpoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapLogPoint", { ctermbg = 0, fg = "#993939", bg = "#31353f" })
vim.api.nvim_set_hl(0, "DapStopped", { ctermbg = 0, fg = "#993939", bg = "#31353f" })

vim.fn.sign_define(
	"DapBreakpoint",
	{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)
vim.fn.sign_define(
	"DapBreakpointCondition",
	{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)
vim.fn.sign_define(
	"DapLogPoint",
	{ text = "ﳁ", texthl = "DapLogPoint", linehl = "DapLogPoint", numhl = "DapLogPoint" }
)
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
vim.fn.sign_define(
	"DapBreakpointRejected",
	{ text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
)
-- :help dap-adapter & :help dap-configuration options for each server

-- Python --
dap.adapters.python = {
	type = "executable",
	command = os.getenv("HOME") .. "/.virtualenvs/debugpy/bin/python",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		-- The first three options are required by nvim-dap
		type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
		request = "launch",
		name = "Launch file",

		-- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
		program = "${file}", -- This configuration will launch the current file if used.
		pythonPath = function()
			-- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
			-- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
			-- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
			-- Following order to be followed "VIRTUAL_ENV", "CONDA_PREFIX",  "asdf shims",

			local command
			local venv_home = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
			local asdfshims = os.getenv("HOME") .. "/.adsf/shims/python"
			if venv_home then
				command = venv_home .. "/bin/python"
			else
				command = asdfshims
			end
			return command
		end,
	},
}
