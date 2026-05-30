require("mcphub").setup({
  auto_approve = true,
  extensions = {
    avante = {
      make_slash_commands = true, -- make /slash commands from MCP server prompts
    },
  },
})
