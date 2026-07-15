local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-lua/plenary.nvim", lazy = true },
  
  -- CDS Syntax Highlighting
  { "preetamkajalrout/cds.vim" },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    config = function() require("nvim-web-devicons").setup({}) end,
  },

  -- Colorscheme
  {
    "olimorris/onedarkpro.nvim",
    name = "onedarkpro",
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        options = {
          transparency = false,
        }
      })
      vim.cmd.colorscheme "onedark"
    end,
  },

  -- Auto Dark Mode
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        pcall(function() vim.cmd("colorscheme onedark") end)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        pcall(function() vim.cmd("colorscheme onelight") end)
      end,
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function() require("custom.plugins.configs.treesitter") end,
  },

  -- Fuzzy Finder
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("custom.plugins.configs.fzflua") end,
  },

  -- Autopairs
  {
    "echasnovski/mini.pairs",
    version = false,
    config = function() require("mini.pairs").setup() end,
  },

  -- File Explorer (Oil.nvim)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true, -- Replaces netrw automatically
        columns = { "icon" },
        view_options = { show_hidden = true },
        keymaps = {
          ["<C-h>"] = false, -- Disable default horizontal split to fix window navigation conflict
          ["<C-s>"] = false, -- Disable default vertical split
          ["<C-x>"] = "actions.select_split",  -- Match FzfLua horizontal split
          ["<C-v>"] = "actions.select_vsplit", -- Match FzfLua vertical split
        },
      })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("custom.plugins.configs.gitsigns") end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("custom.plugins.configs.lualine") end,
  },

  -- Markdown Rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- ASCII Mermaid
  {
    "kais-radwan/ascii-mermaid",
    ft = "markdown",
    cmd = { "MermaidRender", "MermaidRenderAll", "MermaidClear" },
    opts = {},
  },

  -- Autocompletion
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = '*',
    opts = {
      keymap = { 
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },
      appearance = { use_nvim_cmp_as_default = true },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function() require("custom.plugins.lsp") end,
  },

  -- Formatting & Linting
  {
    "stevearc/conform.nvim",
    config = function() require("custom.plugins.configs.conform") end,
  },
  {
    "mfussenegger/nvim-lint",
    config = function() require("custom.plugins.configs.nvimlint") end,
  },

  -- Mini.clue 
  {
    "echasnovski/mini.clue",
    event = "VeryLazy",
    config = function() require("custom.plugins.configs.miniclue") end,
  },

}, {
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
      },
    },
  },
})
