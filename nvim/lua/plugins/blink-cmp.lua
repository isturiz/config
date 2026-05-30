---@module 'blink.cmp'
---@type blink.cmp.Config
require("blink.cmp").setup({
  -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
  -- 'super-tab' for mappings similar to vscode (tab to accept)
  -- 'enter' for enter to accept
  -- 'none' for no mappings
  --
  -- All presets have the following mappings:
  -- C-space: Open menu or open docs if already open
  -- C-n/C-p or Up/Down: Select next/previous item
  -- C-e: Hide menu
  -- C-k: Toggle signature help (if signature.enabled = true)
  --
  -- See :h blink-cmp-config-keymap for defining your own keymap
  keymap = { preset = 'super-tab' },

  appearance = {
    nerd_font_variant = 'mono',
  },

  -- Only show the documentation popup when manually triggered
  completion = { documentation = { auto_show = true } },

  sources = {
    default = { 'copilot', 'lsp', 'avante', 'path', 'snippets', 'buffer' },
    providers = {
      avante = {
        module = 'blink-cmp-avante',
        name = 'Avante',
      },
      copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
      },
    },
  },

  fuzzy = { implementation = "prefer_rust_with_warning" },
})
