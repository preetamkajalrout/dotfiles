local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local km = vim.keymap.set

-- Remap leader key to <space>

km("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Close bindings

km("n", "<leader>s", ":w<CR>", opts)
km("n", "<leader>q", ":q<CR>", opts)
km("n", "<leader>qq", ":q!<CR>", opts)
km("n", "<leader>w", ":bdelete!<CR>", opts) -- closes the current buffer, check :help bdelete; list of buffer => :buffers
km("n", "<leader>wa", ":%bdelete!<CR>:q<CR>", opts) -- closes all the buffers and quits nvim

-- Better window navigation
km("n", "<C-h>", "<C-w>h", opts)
km("n", "<C-j>", "<C-w>j", opts)
km("n", "<C-k>", "<C-w>k", opts)
km("n", "<C-l>", "<C-w>l", opts)

km("n", "<leader>e", ":Lex 30<CR>", opts)

-- Navigate buffer (~ files)
km("n", "<S-h>", ":bprevious<CR>", opts)
km("n", "<S-l>", ":bnext<CR>", opts)

-- Trouble plugin keybinding
km("n", "<leader>xx", "<cmd>TroubleToggle<cr>", opts)
km("n", "<leader>xL", "<cmd>TroubleToggle lsp_references<cr>", opts)

-- Visual --
-- Stay in indent mode
km("v", "<", "<gv", opts)
km("v", ">", ">gv", opts)

-- Move text up & down
km("v", "<A-j>", ":m .+1<CR>gv-gv", opts)
km("v", "<A-k>", ":m .-2<CR>gv-gv", opts)

-- Visual Block --
-- Move text up & down
km("x", "J", ":move '>+1<CR>gv-gv", opts)
km("x", "K", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
km("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
km("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
km("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
km("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

