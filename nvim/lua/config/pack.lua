-- Build hooks — must be registered BEFORE vim.pack.add()
-- Only runs on install/update, not on every startup

local function run_pack_hook(name, cmd, opts)
  opts = vim.tbl_extend('force', { text = true }, opts or {})

  vim.system(cmd, opts, function(obj)
    if obj.code == 0 then return end

    local output = vim.trim(table.concat({ obj.stdout or '', obj.stderr or '' }, '\n'))

    vim.schedule(function()
      vim.notify(
        string.format(
          'Pack hook failed for %s (exit %d): %s%s',
          name,
          obj.code,
          table.concat(cmd, ' '),
          output ~= '' and ('\n\n' .. output) or ''
        ),
        vim.log.levels.ERROR
      )
    end)
  end)
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'avante.nvim' then
      -- Avante needs native Lua libraries. By default this downloads the
      -- prebuilt binaries using curl/tar; source builds require cargo.
      run_pack_hook('avante.nvim', { 'make', 'BUILD_FROM_SOURCE=false' }, { cwd = ev.data.path })

    elseif name == 'nvim-treesitter' then
      -- TSUpdate requires the plugin to already be active
      if ev.data.active then
        vim.cmd('TSUpdate')
      end
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

  -- Avante deps
  gh('MeanderingProgrammer/render-markdown.nvim'),
  gh('stevearc/dressing.nvim'),
  gh('MunifTanjim/nui.nvim'),
  gh('HakonHarnes/img-clip.nvim'),
})
