local server = "/mnt/odools_host/odoo_ls_server"
local odools = "/mnt/odools/odools.toml"
local stdlib = "/mnt/odools_host/typeshed/stdlib"
return {
  cmd = {
    server,
    "--config-path", odools,
    "--stdlib", stdlib,
  },
  filetypes = { "python", "xml", "javascript" },
  root_markers = { "odools.toml" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),

  settings = {
    Odoo = {
      selectedProfile = 'main',
    }
  },
}
