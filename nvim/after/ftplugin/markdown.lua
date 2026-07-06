vim.bo.textwidth = 80

-- Use Vim's built-in paragraph reflow for `gq` in Markdown.
-- This keeps Visual mode + `f` wrapping prose to 80 columns reliably, instead
-- of delegating `gq` to conform/prettierd, whose Markdown prose wrapping can be
-- affected by project prettier config or daemon state.
vim.bo.formatexpr = ""
