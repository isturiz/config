require("lualine").setup({
  options = {
    globalstatus = true,
  },

  sections = {
    lualine_c = { { "filename", file_status = true, path = 1 } },
    lualine_x = { "filetype" },
  },

  inactive_winbar = {
    lualine_c = { "filename" },
  },
})
