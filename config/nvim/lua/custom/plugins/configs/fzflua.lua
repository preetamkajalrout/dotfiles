local actions = require("fzf-lua.actions")

require("fzf-lua").setup({
  "default",
  winopts = { preview = { default = 'bat' } },
  fzf_opts = {
    ["--bind"] = "ctrl-n:down,ctrl-p:up",
  },
  actions = {
    files = {
      ["default"] = actions.file_edit,
      ["ctrl-t"]  = actions.file_tabedit,
      ["alt-q"]   = actions.file_sel_to_qf,
      ["ctrl-s"]  = false,
      ["ctrl-x"]  = false,
      ["ctrl-v"]  = false,
      ["ctrl-h"]   = actions.file_vsplit,
      ["ctrl-l"]   = actions.file_vsplit,
      ["ctrl-j"]   = actions.file_split,
      ["ctrl-k"]   = actions.file_split,
    },
    buffers = {
      ["default"] = actions.buf_switch,
      ["ctrl-t"]  = actions.buf_tabedit,
      ["ctrl-s"]  = false,
      ["ctrl-x"]  = false,
      ["ctrl-v"]  = false,
      ["ctrl-h"]   = actions.buf_vsplit,
      ["ctrl-l"]   = actions.buf_vsplit,
      ["ctrl-j"]   = actions.buf_split,
      ["ctrl-k"]   = actions.buf_split,
    },
  },
})
