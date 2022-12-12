-- :help options

local options = {
  backup = false,                       -- creates a backup file
  clipboard = "unnamedplus", 		-- allows neovim to access system clipboard; also supports wsl2 based setup with win32yank.exe
  fileencoding = "utf-8",			-- default encoding for files
  hlsearch = true,				-- hightlight all matches for previous search pattern
  ignorecase = true,			-- ignore case in search pattern
  showmode = false,			-- hides the mode in default status line e.g. -- INSERT -- is hidden, since lualine takes of this
  showtabline = 2,			-- always show tabs
  smartcase = true,			-- respects case if search pattern contains UPPERCASE letter ignoring opt.ignorecase settings
  autoindent = true,			-- starts next line with indent based on current line
  smartindent = true,			-- specifies indent automatically with certain condition for c-like languages
  swapfile = true,				-- swap file help keep a delta in-memory to recover easily -- more to be read on this
  splitright = true,			-- force open vertical split to right
  splitbelow = true,			-- force open horizontal split to bottom
  termguicolors = true,			-- supports more colors in modern shell emulators
  undofile = true,				-- enables persistence undo
  updatetime = 300,			-- faster completion (default: 4000ms) -- TODO: yet to know how this affects faster completion
  writebackup = false,			-- Doesn't change if the open file is edited/changed in another software
  expandtab = true,			-- converts tab to spaces
  shiftwidth = 2,				-- no. of spaces inserted for each indentation
  tabstop = 2,				-- inserts 2 spaces for a tab
  cursorline = true,			-- highlight the current line
  number = true,                 -- set line numbers to show
  relativenumber = false,        -- keep the line number in sequence
  signcolumn = "yes",            -- always show the signcolumn to avoid text display movement
  wrap = false,                  -- display lines in one long line
  scrolloff = 8,                 -- keeps 8 lines extra shown around cursor line vertically; better if reading through code
  sidescrolloff = 8,            -- same as above except columns are shown horizontally;
  completeopt = "menu,menuone,noselect", -- sets up behaviour for completion popup and force select from the popup
  timeoutlen = 500,           -- makes 'which-key' popup faster
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
