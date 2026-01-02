return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/yaml-language-server", "--stdio" },
  filetypes = { "yaml" }, -- "yml" suele ser innecesario (extensión != filetype)
  root_markers = { ".git" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      format = {
        enable = true,
        singleQuote = false,
        bracketSpacing = true,
        proseWrap = "preserve",
        printWidth = 120,
      },
      validate = true,
      hover = true,
      completion = true,
      schemaStore = { enable = true },
    },
  },
}
