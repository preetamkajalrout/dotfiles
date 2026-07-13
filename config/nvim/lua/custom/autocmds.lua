-- Custom Autocommands
-- For help see :help api-autocmd

-- Automatically change the working directory if Neovim is started with a directory as an argument
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argv = vim.fn.argv()
    if #argv > 0 then
      local path = argv[1]
      if vim.fn.isdirectory(path) == 1 then
        vim.cmd.cd(path)
      end
    end
  end,
})

-- Automatically configure folding when opening specific file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "cds" },
  callback = function()
    -- Indent-based folding is 100% bulletproof for curly-brace languages 
    -- and bypasses all Treesitter parser load issues.
    vim.opt_local.foldmethod = "indent"
    
    -- Fold all function/entity bodies, leaving level 1 definitions visible
    vim.opt_local.foldlevel = 1
  end,
})
