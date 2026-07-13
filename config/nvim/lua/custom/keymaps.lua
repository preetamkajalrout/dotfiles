-- Remap leader key to <space>
vim.keymap.set("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper function for clean keymaps
local function km(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Normal --
-- Close bindings
km("n", "<leader>s", ":w<CR>", "Save file")
km("n", "<leader>q", ":q<CR>", "Quit file")
km("n", "<leader>qq", ":q!<CR>", "Force quit file")
km("n", "<leader>w", ":bdelete!<CR>", "Close buffer")
km("n", "<leader>wa", ":%bdelete!<CR>:q<CR>", "Close all buffers and quit")

-- Better window navigation
km("n", "<C-h>", "<C-w>h", "Window Left")
km("n", "<C-j>", "<C-w>j", "Window Down")
km("n", "<C-k>", "<C-w>k", "Window Up")
km("n", "<C-l>", "<C-w>l", "Window Right")

-- Toggle maximize split (retains exact original window layout dimensions)
local restore_maximized_win = nil
km("n", "<leader>m", function()
  if restore_maximized_win then
    pcall(vim.cmd, restore_maximized_win)
    restore_maximized_win = nil
  else
    restore_maximized_win = vim.fn.winrestcmd()
    vim.cmd("wincmd _")
    vim.cmd("wincmd |")
  end
end, "Toggle Maximize Split")

-- Smart split resizer to move the border visually in the direction pressed
local function resize_split(direction, amount)
  local cur_win = vim.fn.winnr()
  if direction == "left" then
    if vim.fn.winnr("l") ~= cur_win then
      vim.cmd("vertical resize -" .. amount)
    else
      vim.cmd("vertical resize +" .. amount)
    end
  elseif direction == "right" then
    if vim.fn.winnr("l") ~= cur_win then
      vim.cmd("vertical resize +" .. amount)
    else
      vim.cmd("vertical resize -" .. amount)
    end
  elseif direction == "up" then
    if vim.fn.winnr("j") ~= cur_win then
      vim.cmd("resize -" .. amount)
    else
      vim.cmd("resize +" .. amount)
    end
  elseif direction == "down" then
    if vim.fn.winnr("j") ~= cur_win then
      vim.cmd("resize +" .. amount)
    else
      vim.cmd("resize -" .. amount)
    end
  end
end

km("n", "<A-Up>", function() resize_split("up", 2) end, "Visual Resize Up")
km("n", "<A-Down>", function() resize_split("down", 2) end, "Visual Resize Down")
km("n", "<A-Left>", function() resize_split("left", 2) end, "Visual Resize Left")
km("n", "<A-Right>", function() resize_split("right", 2) end, "Visual Resize Right")

km("n", "<leader>e", function() require("oil").toggle_float() end, "File Explorer")

-- Navigate buffer (~ files)
km("n", "<S-h>", ":bprevious<CR>", "Previous Buffer")
km("n", "<S-l>", ":bnext<CR>", "Next Buffer")

-- Visual --
-- Stay in indent mode
km("v", "<", "<gv", "Indent left")
km("v", ">", ">gv", "Indent right")

-- Move text up & down
km("v", "<A-j>", ":m .+1<CR>gv-gv", "Move text down")
km("v", "<A-k>", ":m .-2<CR>gv-gv", "Move text up")

-- FzfLua keymaps
km("n", "<leader>f", ":FzfLua<CR>", "FzfLua Menu")
km("n", "<leader>fm", function()
  require("fzf-lua").marks({
    winopts = { height = 0.40, width = 0.50, preview = { hidden = "hidden" } }
  })
end, "Find Marks")
km("n", "<C-p>", ":FzfLua files<CR>", "Find Files")
km("n", "<leader>fg", ":FzfLua live_grep<CR>", "Find Text (Project)")

km("n", "<leader>fb", function()
  require("fzf-lua").buffers({
    winopts = { preview = { hidden = "hidden" }, height = 0.40, width = 0.50 }
  })
end, "Find Buffers")

-- ==========================================
-- Reusable Floating Terminal Utility
-- ==========================================
local function open_floating_term(cmd)
  -- Create a completely empty, unlisted buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Calculate window size (95% of the screen to prevent clipping the bottom bar)
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.95)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Pop open the floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded"
  })

  -- Start the terminal process inside the buffer
  vim.fn.termopen(cmd, {
    on_exit = function()
      -- Automatically close the floating window when you quit the process!
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end
  })

  -- Instantly drop into insert mode so you can interact with the CLI
  vim.cmd("startinsert")
end

-- Map <leader>gg to open GitUI in the floating terminal
km("n", "<leader>gg", function() open_floating_term("gitui") end, "GitUI (Floating)")

-- Diagnostics & LSP 
km("n", "<leader>xx", ":FzfLua diagnostics_document<CR>", "Document Diagnostics")
km("n", "<leader>xW", ":FzfLua diagnostics_workspace<CR>", "Workspace Diagnostics")
km("n", "<leader>xr", ":FzfLua lsp_references<CR>", "LSP References")
