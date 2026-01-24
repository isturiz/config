local root = vim.fn.getcwd()
local schema = root .. "/schemas/mapping.schema.json"
local schemas = {}

if vim.loop.fs_stat(schema) then
  schemas[schema] = {
    root .. "/mapping.yaml",
    root .. "/mapping/*.yaml",
  }
end

return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
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
      schemas = schemas,
    },
  },
}
