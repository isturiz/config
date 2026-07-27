---@type vim.lsp.Config
local root_markers = {
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

return {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if not vim.fs.root(path, "odools.toml") then
      on_dir(vim.fs.root(path, root_markers))
    end
  end,
  single_file_support = true,
}
