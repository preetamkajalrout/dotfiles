local ts_status_ok, telescope = pcall(require, "telescope")
if not ts_status_ok then
  vim.notify("`nvim-telescope/telescope.nvim` couldn't be loaded!", "error", {
    title = "telescope.nvim"
  })
  return
end

telescope.setup()

-- Key mappings for telescope 
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
