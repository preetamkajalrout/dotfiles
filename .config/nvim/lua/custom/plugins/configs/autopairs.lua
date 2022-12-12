local ap_status_ok, npairs = pcall(require, "nvim-autopairs")
if not ap_status_ok then
  vim.notify("nvim-autopairs couldn't be loaded!", "error", {
    title = "windwp/nvim-autopairs"
  })
  return
end

-- change default fast_wrap
npairs.setup({
  check_ts = true,
  ts_config = { -- REVISIT: check how these settings affect lua & javascript
    lua = { "string", "source" }, -- it will not add a pair on that treesitter node
    javascript = { "string", "template_string" },
  },
  disable_filetype = { "TelescopePrompt" },
  fast_wrap = {
    map = '<A-e>', -- REVISIT: Meta/Alt key doesn't work
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = '$',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey='Comment'
  },
})

local ap_status_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
if not ap_status_ok then
  vim.notify("nvim-autopairs completion couldn't be loaded!", "error", {
    title = "windwp/nvim-autopairs"
  })
  return
end

local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  vim.notify("nvim-cmp couldn't be loaded!", "error", {
    title = "hrsh7th/nvim-cmp"
  })
  return
end

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
