-- Git commit messages use a 72-column body by convention.
vim.bo.textwidth = 72

-- Use Vim's built-in paragraph formatter for commit messages. This overrides
-- the global Conform formatexpr, which has no formatter for `gitcommit`.
vim.bo.formatexpr = ""

-- Keep long lines readable while editing, without inserting line breaks until
-- the buffer is explicitly formatted with `gq`.
vim.wo.wrap = true
vim.wo.linebreak = true

-- Format the current paragraph from normal mode. Support both cases since
-- <leader>f and <leader>F are different mappings in Vim.
vim.keymap.set("n", "<leader>f", "gqap", { buffer = true, desc = "Format commit paragraph" })
vim.keymap.set("n", "<leader>F", "gqap", { buffer = true, desc = "Format commit paragraph" })

-- Format a selected portion from visual mode.
vim.keymap.set("x", "f", "gq", { buffer = true, desc = "Format selected commit text" })
vim.keymap.set("x", "F", "gq", { buffer = true, desc = "Format selected commit text" })
