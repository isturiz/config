vim.schedule(function()
  -- Avante visual dependencies setup
  require("img-clip").setup({
    default = {
      embed_image_as_base64 = false,
      prompt_for_file_name = false,
      drag_and_drop = {
        insert_mode = true,
      },
      use_absolute_path = true,
    },
  })

  -- Avante main setup
  require("avante").setup({
    provider = "copilot",
    --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | string
    file_selector = {
      provider = "snacks",
    },
    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },
    hints = { enabled = false },
    windows = {
      ---@type "right" | "left" | "top" | "bottom" | "smart"
      position = "smart",
      wrap = true,
      width = 50,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = false,
      },
      input = {
        prefix = "> ",
        height = 8,
      },
      edit = {
        start_insert = true,
      },
      ask = {
        floating = false,
        start_insert = true,
        ---@type "ours" | "theirs"
        focus_on_apply = "ours",
      },
    },
    highlights = {
      ---@type AvanteConflictHighlights
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    --- @class AvanteConflictUserConfig
    diff = {
      autojump = true,
      ---@type string | fun(): any
      list_opener = "copen",
      override_timeoutlen = 500,
    },

    -- system_prompt as a function ensures the LLM always has the latest MCP
    -- server state (evaluated on every message)
    system_prompt = function()
      local hub = require("mcphub").get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ""
    end,
    custom_tools = function()
      return {
        require("mcphub.extensions.avante").mcp_tool(),
      }
    end,

    -- MCP Hub covers these operations; disabling Avante's to avoid duplicates
    disabled_tools = {
      "list_files",
      "search_files",
      "read_file",
      "create_file",
      "rename_file",
      "delete_file",
      "create_dir",
      "rename_dir",
      "delete_dir",
      "bash",
    },
  })

  -- AI action recipes (context-aware keymaps in visual mode)
  require("meta-plugins.avante.recipes")
end)
