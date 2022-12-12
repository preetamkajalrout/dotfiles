local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugininit.lua file
vim.cmd([[
  augroup packer_user_config 
    autocmd! 
    autocmd BufWritePost plugininit.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Generic plugins or used by others 
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use "rcarriga/nvim-notify" -- Fancy notification plugin
  use { -- dev icons required by tools like telescope & more
    "nvim-tree/nvim-web-devicons",
    config = function () require("nvim-web-devicons").setup({}) end
  }
  use {
    "akinsho/bufferline.nvim",
    tag = "v3.*",
    requires = "nvim-tree/nvim-web-devicons",
    config = function () require("bufferline").setup({}) end
  }
  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup({}) end
  }
  use "numToStr/Comment.nvim"
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }
  }
  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function () require("indent_blankline").setup({ show_current_context = true, show_current_context_start = true }) end
  }
  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim", opt = true }
  }

  -- Theme Plugin -- Configuration for the same should be available in colorscheme.lua
  use "navarasu/onedark.nvim" -- Onedark theme

  -- Completion plugins
  use "hrsh7th/nvim-cmp" -- The completion plugin
  use "hrsh7th/cmp-buffer" -- buffer completion (from file being edited)
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- command line completionsuse
  use "saadparwaiz1/cmp_luasnip" -- Snippets
  use "hrsh7th/cmp-nvim-lsp" -- LSP source for nvim-cmp

  -- snippets
  use "L3MON4D3/LuaSnip" -- snip engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- LSP -- order of the mason and lspconfig is important
  use {
    "williamboman/mason.nvim",
    config = function () require("mason").setup({
      ui = {
        icons = { -- Icons refered from NvChad config
          package_pending = " ",
          package_installed = " ",
          package_uninstalled = " ﮊ",
        }
      }
    }) end
  }
  use {
    "williamboman/mason-lspconfig.nvim",
    config = function () require("mason-lspconfig").setup() end
  }
  use {
    "neovim/nvim-lspconfig"
  }

  -- Tree-sitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end
  }
  -- use "p00f/nvim-ts-rainbow"
  use "nvim-treesitter/nvim-treesitter-context"
  use "nvim-treesitter/nvim-treesitter-refactor"
  use "JoosepAlviste/nvim-ts-context-commentstring"

  -- Telescope
  use { "nvim-telescope/telescope.nvim", tag = "0.1.0",
    requires = { {"nvim-lua/plenary.nvim"} }
  }

  -- Git
  use "lewis6991/gitsigns.nvim"

  -- wakatime
  use "wakatime/vim-wakatime"

  -- whichkey
  use "folke/which-key.nvim"

  -- nvm-dap debugging plugins
  use "mfussenegger/nvim-dap"
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use { "mxsdev/nvim-dap-vscode-js", requires = {"mfussenegger/nvim-dap"} }
  use {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npm run compile"
  }
  -- Trouble -- used to show code diagnostics in a pane
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup({})
    end
  }
  -- Terminal
  use "numToStr/FTerm.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
