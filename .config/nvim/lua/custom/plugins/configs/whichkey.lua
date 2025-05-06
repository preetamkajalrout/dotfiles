local wk_present, wk = pcall(require, "which-key")
if not wk_present then
	vim.notify("which-key couldn't be loaded!", "error", {
		title = "folke/which-key.nvim",
	})
	return
end

wk.setup({}) -- keeping it blank, will change it based on usage

local M = {}

M.name = "custom"

M.visual = {
	["<"] = { "<gv", "Shift left" },
	[">"] = { ">gv", "Shift right" },

  -- Move text up & down
  ["<A-j>"] = { ":m .+1<CR>gv-gv" , "Move text down" },
  ["<A-k>"] = { ":m .-2<CR>gv-gv" , "Move text up" },
}

M.terminal = {
  ["<C-h>"] = { "<C-\\><C-N><C-w>h", "Terminal Left" },
  ["<C-j>"] = { "<C-\\><C-N><C-w>h", "Terminal down" },
  ["<C-k>"] = { "<C-\\><C-N><C-w>h", "Terminal up" },
  ["<C-l>"] = { "<C-\\><C-N><C-w>h", "Terminal right" },
}

M.normal = {
	-- Close & save bindings
	["<leader>s"] = { ":w<CR>", "Save current buffer" },
	["<leader>q"] = { ":q<CR>", "Exit nvim if no changes" },
	["<leader>qq"] = { ":q!<CR>", "Exit nvim without save" },
	["<leader>w"] = { ":bdelete!<CR>", "Close/Delete the current buffer" },
	["<leader>wa"] = { ":%bdelete!<CR>:q<CR>", "Close/Delete all buffer & exit nvim" },

	-- Toggle File Explorer
	["<leader>e"] = { ":NvimTreeToggle<CR>", "Toggle File explorer" },

  -- Better window navigation
  ["<C-h>"] = { "<C-w>h", "Window: Move left" },
  ["<C-j>"] = { "<C-w>j", "Window: Move down" },
  ["<C-k>"] = { "<C-w>k", "Window: Move up" },
  ["<C-l>"] = { "<C-w>l", "Window: Move right" },
  
  -- Navigate buffer
  ["<S-h>"] = { ":bprevious<CR>", "Previous buffer/tab" },
  ["<S-l>"] = { ":bnext<CR>", "Next buffer/tab" },
}


wk.register(M.visual, { mode = "v" })
wk.register(M.normal, { mode = "n" })
wk.register(M.terminal, { mode = "t" })

-- Register plugin specific keybindings
M.trouble = {
  ["<leader>x"] = {
    name = "+trouble",
    x = { "<cmd>TroubleToggle<cr>" , ""},
    L = { "<cmd>TroubleToggle lsp_references<cr>", "" }
  }
}

wk.register(M.trouble, { mode = "n" })

M.fterm = {
  ["<A-t>"] = { "Toggle Terminal" }, -- which-key only registers for normal mode for reference
  ["<A-f>"] = {
    name = "+Popup Terminal",
    l = "Open Lazygit",
    b = "Open top",
    n = "Open Nodejs repl",
    p = "Open Python repl",
  }
}
wk.register(M.fterm, { mode = "n" })

M.telescope = {
  ["<leader>f"] = {
    name = "+Telescope",
    f = "TS: Find Files",
    g = "TS: Find with grep",
    b = "TS: Find buffers",
    h = "TS: Find help_tags",
  }
}
wk.register(M.telescope, { mode = "n" })

M.lsp = {
  
}
wk.register(M.lsp, { mode = "n" })

M.dap = {
  
}
wk.register(M.dap, { mode = "n" })



