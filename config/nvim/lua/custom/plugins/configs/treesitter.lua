local ts_status_ok, treesitter_cfg = pcall(require, "nvim-treesitter.configs")
if not ts_status_ok then
  vim.notify("nvim-treesitter couldn't be loaded", "error", {
    title = "nvim-treesitter/nvim-treesitter"
  })
  return
end


treesitter_cfg.setup({
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "python", "javascript" }, -- parsers with maintainers 
  sync_install = false,
  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true,
    disable = { "yaml", "python" }
  },
  autopairs = {
    enable = true
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if we have an `updatetime` of ~100.
      clear_on_cursor_move = true,
    },
    highlight_current_scope = { enable = false },
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr",
      },
    },
  },
})
