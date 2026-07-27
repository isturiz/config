---@type vim.lsp.Config
local root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" }

return {
  init_options = { hostInfo = "neovim" },
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  root_dir = function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if not vim.fs.root(path, "odools.toml") then
      on_dir(vim.fs.root(path, root_markers))
    end
  end,
  single_file_support = true,
}
