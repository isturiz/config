---@type vim.lsp.Config
return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/lemminx" },
  filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if not vim.fs.root(path, "odools.toml") then
      on_dir(vim.fs.root(path, ".git"))
    end
  end,
}
