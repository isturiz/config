require("copilot").setup({
  server_opts_overrides = {
    settings = {
      telemetry = {
        telemetryLevel = "off",
      },
    },
  },

  workspace_folders = {
    "~/workspace",
    "~/config",
  },

  should_attach = function(_, bufname)
    if string.match(bufname, "env") then
      return false
    end
    return true
  end,

  suggestion = { enabled = false },
  panel = { enabled = false },
})
