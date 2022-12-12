local status_ok, comment = pcall(require, "Comment")
if not status_ok then
  vim.notify("comment couldn't be loaded!", "error", {
    title = "numToStr/Comment.nvim"
  })
  return
end

comment.setup { -- REVISIT: This is copied piece from Lunarvim config, understand it
  pre_hook = function(ctx)
    local U = require "Comment.utils"

    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring {
      key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
      location = location,
    }
  end,
}
