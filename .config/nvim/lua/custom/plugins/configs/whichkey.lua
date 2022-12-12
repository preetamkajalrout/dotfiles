local wk_present, wk = pcall(require, "which-key")
if not wk_present then
  vim.notify("which-key couldn't be loaded!", "error", {
    title = "folke/which-key.nvim"
  })
  return
end

wk.setup({}) -- keeping it blank, will change it based on usage
