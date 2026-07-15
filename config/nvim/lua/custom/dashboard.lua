local M = {}

local ns_id = vim.api.nvim_create_namespace("dashboard_highlights")

function M.create_dashboard()
  -- Create a new unlisted scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "dashboard")

  -- Set buffer to active window
  vim.api.nvim_set_current_buf(buf)

  -- Hide UI decorations for this buffer
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.signcolumn = "no"
  vim.opt_local.cursorline = false

  -- Dynamic highlight groups from theme
  local special_fg = vim.api.nvim_get_hl(0, { name = "Special" }).fg
  vim.api.nvim_set_hl(0, "DashboardTitle", { link = "Title" })
  vim.api.nvim_set_hl(0, "DashboardSubtitle", { link = "Comment" })
  vim.api.nvim_set_hl(0, "DashboardItalic", { italic = true, fg = special_fg })
  vim.api.nvim_set_hl(0, "DashboardFooter", { link = "Comment" })

  local header = {
    [[ ██████╗ ██████╗ ███████╗███████╗████████╗ █████╗ ███╗   ███╗ ]],
    [[ ██╔══██╗██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗████╗ ████║ ]],
    [[ ██████╔╝██████╔╝█████╗  █████╗     ██║   ███████║██╔████╔██║ ]],
    [[ ██╔═══╝ ██╔══██╗██╔══╝  ██╔══╝     ██║   ██╔══██║██║╚██╔╝██║ ]],
    [[ ██║     ██║  ██║███████╗███████╗   ██║   ██║  ██║██║ ╚═╝ ██║ ]],
    [[ ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝ ]],
    [[]],
    [[            ⚡ welcome back, to nvim ⚡          ]],
  }

  local buttons = {
    { key = "f", label = "Find File (FzfLua)", cmd = ":FzfLua files<CR>" },
    { key = "r", label = "Recent Files (FzfLua)", cmd = ":FzfLua oldfiles<CR>" },
    { key = "g", label = "Find Text (FzfLua)", cmd = ":FzfLua live_grep<CR>" },
    { key = "n", label = "New File", cmd = ":ene <BAR> startinsert<CR>" },
    { key = "q", label = "Quit Neovim", cmd = ":qa<CR>" },
  }

  local function draw()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)

    -- Dynamic startup time
    local start_time = require("lazy").stats().startuptime
    local footer_text = string.format("Started neovim in %.1f ms", start_time)

    -- Calculate vertical padding (centering)
    local total_height = #header + (#buttons * 2) + 5
    local vertical_pad = math.max(1, math.floor((win_height - total_height) / 2) - 2)

    local lines = {}
    for _ = 1, vertical_pad do
      table.insert(lines, "")
    end

    -- Add header (centered horizontally)
    for _, line in ipairs(header) do
      local display_w = vim.fn.strdisplaywidth(line)
      local pad = math.max(0, math.floor((win_width - display_w) / 2))
      table.insert(lines, string.rep(" ", pad) .. line)
    end

    table.insert(lines, "")
    table.insert(lines, "")

    -- Add buttons (centered horizontally)
    for _, button in ipairs(buttons) do
      local text = string.format("[%s]  %s", button.key, button.label)
      local display_w = vim.fn.strdisplaywidth(text)
      local pad = math.max(0, math.floor((win_width - display_w) / 2))
      table.insert(lines, string.rep(" ", pad) .. text)
      table.insert(lines, "") -- spacer line
    end

    table.insert(lines, "")

    -- Add footer (centered horizontally)
    local footer_pad = math.max(0, math.floor((win_width - vim.fn.strdisplaywidth(footer_text)) / 2))
    table.insert(lines, string.rep(" ", footer_pad) .. footer_text)

    -- Render the lines
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    -- Clear old highlights
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    -- Highlight logo (lines 1 to 6)
    for idx = 1, 6 do
      local line_idx = vertical_pad + (idx - 1)
      vim.api.nvim_buf_add_highlight(buf, ns_id, "DashboardTitle", line_idx, 0, -1)
    end

    -- Highlight "welcome back, to nvim" subheader
    local sub_line_idx = vertical_pad + 7
    local sub_line_text = header[8]
    local sub_pad = math.max(0, math.floor((win_width - vim.fn.strdisplaywidth(sub_line_text)) / 2))

    -- Find byte offsets dynamically
    local start_sub, end_sub = string.find(sub_line_text, "welcome back, to ")
    local start_italic, end_italic = string.find(sub_line_text, "nvim")

    if start_sub and end_sub then
      vim.api.nvim_buf_add_highlight(buf, ns_id, "DashboardSubtitle", sub_line_idx, sub_pad + start_sub - 1, sub_pad + end_sub)
    end
    if start_italic and end_italic then
      vim.api.nvim_buf_add_highlight(buf, ns_id, "DashboardItalic", sub_line_idx, sub_pad + start_italic - 1, sub_pad + end_italic)
    end

    -- Highlight keys
    for i, button in ipairs(buttons) do
      local text = string.format("[%s]  %s", button.key, button.label)
      local display_w = vim.fn.strdisplaywidth(text)
      local pad = math.max(0, math.floor((win_width - display_w) / 2))
      local btn_line_idx = vertical_pad + #header + 2 + (i - 1) * 2
      vim.api.nvim_buf_add_highlight(buf, ns_id, "Keyword", btn_line_idx, pad + 1, pad + 1 + #button.key)
    end

    -- Highlight footer
    local footer_line_idx = vertical_pad + #header + 2 + (#buttons * 2) + 1
    vim.api.nvim_buf_add_highlight(buf, ns_id, "DashboardFooter", footer_line_idx, 0, -1)
  end

  -- Set buffer local mappings
  for _, button in ipairs(buttons) do
    vim.api.nvim_buf_set_keymap(buf, "n", button.key, button.cmd, { noremap = true, silent = true })
  end

  -- Prevent editing keypresses
  local nop_keys = { "i", "a", "o", "O", "h", "j", "k", "l", "<Up>", "<Down>", "<Left>", "<Right>" }
  for _, key in ipairs(nop_keys) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, "<Nop>", { noremap = true, silent = true })
  end

  -- Draw initially
  draw()

  -- Redraw on resize
  vim.api.nvim_create_autocmd("VimResized", {
    buffer = buf,
    callback = draw,
  })
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local argc = vim.fn.argc()
      local is_dir = false
      if argc == 1 then
        local arg = vim.fn.argv(0)
        is_dir = vim.fn.isdirectory(arg) == 1 or string.match(arg, "^oil://") ~= nil
      end

      if argc == 0 or is_dir then
        -- Schedule both cases to guarantee colorschemes have finished initializing
        vim.schedule(M.create_dashboard)
        
        -- Wipe out other buffers if opening a directory
        if is_dir then
          vim.schedule(function()
            local current_buf = vim.api.nvim_get_current_buf()
            for _, b in ipairs(vim.api.nvim_list_bufs()) do
              if b ~= current_buf then
                vim.api.nvim_buf_delete(b, { force = true })
              end
            end
          end)
        end
      end
    end
  })
end

return M
