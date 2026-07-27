---@type vim.lsp.Config
local install_dir = vim.fn.stdpath("data") .. "/odoo"

return {
  cmd = { install_dir .. "/odoo_ls_server", "--log-level", "info" },
  filetypes = { "python", "xml", "csv", "javascript", "typescript" },
  root_markers = { "odools.toml" },
  single_file_support = false,
  settings = {
    Odoo = {
      selectedProfile = "default",
    },
  },
}
