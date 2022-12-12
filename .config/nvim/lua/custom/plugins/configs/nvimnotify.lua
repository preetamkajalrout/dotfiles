-- Replace vim.notify due to notify
require("notify").setup({
  stages = "slide",
  timeout = 2000
})
vim.notify = require("notify")
vim.notify("`vim.notify` is now set", "info", {
  title = "nvim-notify"
})
