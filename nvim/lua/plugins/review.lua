require("review").setup({
  keymaps = {
    toggle = "<leader>rv",
  },
  ui = {
        number_navigation = true,
    },
})

vim.keymap.set("n", "<leader>re", "<cmd>Review export<CR>", { desc = "Copy review comments" })
