local nls = require("null-ls")

require("null-ls").setup({
  sources = {
    nls.builtins.formatting.black,
  },
})
