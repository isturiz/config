vim.schedule(function()
  -- nvim-treesitter was rewritten: highlight and indent are built-in in Neovim 0.12
  -- Minimal setup — only accepts `install_dir` if you want to change the parser path
  require("nvim-treesitter").setup()

  -- nvim-ts-autotag: independent setup (no longer part of nvim-treesitter.configs)
  require("nvim-ts-autotag").setup()

  -- nvim-treesitter-textobjects: independent setup
  require("nvim-treesitter-textobjects").setup({
    select = {
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
      },
    },
  })
end)

-- Parsers: install manually with :TSInstall or :TSUpdate
-- Recommended for this config:
-- :TSInstall lua luadoc javascript typescript html css markdown markdown_inline
-- :TSInstall rust svelte astro python bash csv json tsx php phpdoc regex tmux angular arduino
