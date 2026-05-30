require('config.keymaps')
require('config.options')
require('config.pack') -- vim.pack.add() + build hooks

-- Plugin setups (order matters)
require('plugins.colorscheme')    -- colorscheme first, before any UI
require('plugins.mini-icons')     -- icons used by lualine, oil, snacks, etc.
require('plugins.copilot')        -- AI base, before blink-copilot source
require('plugins.blink-cmp')      -- completion, must be before after/plugin/lsp.lua
require('plugins.snacks')         -- UI hub (notifier, picker, terminal, etc.)
require('plugins.which-key')
require('plugins.lualine')
require('plugins.oil')
require('plugins.harpoon')
require('plugins.gitsigns')
require('plugins.gitblame')
require('plugins.tree-sitter')    -- before avante
require('plugins.autopairs')
require('plugins.conform')
require('plugins.none-ls')
require('plugins.mason')
require('plugins.render-markdown') -- before avante (visual dep)
require('plugins.avante')          -- includes img-clip setup
require('plugins.mcp-hub')         -- after avante
