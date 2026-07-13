local actions = require("fzf-lua.actions")

require("fzf-lua").setup({
  "default",
  winopts = { preview = { default = 'bat' } },
  actions = {
    files = {
      ["default"] = actions.file_edit,
      ["ctrl-x"]  = actions.file_split,
      ["ctrl-v"]  = actions.file_vsplit,
      ["ctrl-t"]  = actions.file_tabedit,
      ["alt-q"]   = actions.file_sel_to_qf,
      ["ctrl-s"]  = false,
    },
    buffers = {
      ["default"] = actions.buf_switch,
      ["ctrl-x"]  = actions.buf_split,
      ["ctrl-v"]  = actions.buf_vsplit,
      ["ctrl-t"]  = actions.buf_tabedit,
      ["ctrl-s"]  = false,
    },
  },
})
