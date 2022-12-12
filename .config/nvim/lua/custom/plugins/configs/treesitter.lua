local ts_status_ok, treesitter_cfg = pcall(require, "nvim-treesitter.configs")
if not ts_status_ok then
  vim.notify("nvim-treesitter couldn't be loaded", "error", {
    title = "nvim-treesitter/nvim-treesitter"
  })
  return
end


treesitter_cfg.setup({
  -- A list of parser names, or "all"
  ensure_installed = { "c", "lua", "rust", "go", "python", "javascript" }, -- parsers with maintainers 
  sync_install = false,
  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = { "yaml" }
  },
  autopairs = {
    enable = true
  },
  rainbow = { -- remove this plugin in case of error `invalid node at position xxx`
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
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
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
})
