-- Build hooks — must be registered BEFORE vim.pack.add()
-- Only runs on install/update, not on every startup
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'avante.nvim' then
      vim.system({ 'make' }, { cwd = ev.data.path })

    elseif name == 'nvim-treesitter' then
      -- TSUpdate requires the plugin to already be active
      if ev.data.active then
        vim.cmd('TSUpdate')
      end

    elseif name == 'mcphub.nvim' then
      vim.system({ 'npm', 'install', '-g', 'mcp-hub@latest' })
    end
  end,
})

local gh = function(r) return 'https://github.com/' .. r end

vim.pack.add({
  -- Core deps
  gh('nvim-lua/plenary.nvim'),

  -- Completion
  { src = gh('saghen/blink.cmp'), version = vim.version.range('>=1.0, <2.0') },
  gh('rafamadriz/friendly-snippets'),
  gh('fang2hou/blink-copilot'),
  gh('Kaiser-Yang/blink-cmp-avante'),

  -- Treesitter
  gh('nvim-treesitter/nvim-treesitter'),
  gh('nvim-treesitter/nvim-treesitter-textobjects'),
  gh('windwp/nvim-ts-autotag'),

  -- UI / UX
  gh('folke/snacks.nvim'),
  gh('folke/which-key.nvim'),
  gh('sainnhe/sonokai'),
  gh('nvim-lualine/lualine.nvim'),
  gh('nvim-tree/nvim-web-devicons'),
  gh('echasnovski/mini.icons'),

  -- File management
  gh('stevearc/oil.nvim'),
  { src = gh('ThePrimeagen/harpoon'), name = 'harpoon', version = 'harpoon2' },

  -- Git
  gh('lewis6991/gitsigns.nvim'),
  gh('f-person/git-blame.nvim'),

  -- Editing
  gh('windwp/nvim-autopairs'),
  gh('stevearc/conform.nvim'),
  gh('nvimtools/none-ls.nvim'),

  -- Tools / LSP management
  gh('mason-org/mason.nvim'),

  -- AI
  gh('zbirenbaum/copilot.lua'),
  gh('yetone/avante.nvim'),
  gh('ravitemer/mcphub.nvim'),

  -- Avante deps
  gh('MeanderingProgrammer/render-markdown.nvim'),
  gh('stevearc/dressing.nvim'),
  gh('MunifTanjim/nui.nvim'),
  gh('HakonHarnes/img-clip.nvim'),
})
