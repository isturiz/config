require("conform").setup({
  formatters_by_ft = {
    ["python"] = { "black" },
    ["markdown"] = { "prettierd" },
    ["markdown.mdx"] = { "prettierd" },
  },
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
