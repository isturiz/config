require("gitblame").setup({
  enabled = true,
  message_template = " <summary> • <date> • <author> • <<sha>>",
  date_format = "%d-%m-%Y %H:%M:%S",
  virtual_text_column = 1,
})

vim.keymap.set("n", "<leader>gB", ":GitBlameOpenCommitURL<CR>", { desc = "Git Blame Commit URL" })
