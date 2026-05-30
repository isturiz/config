-- ============================================================
-- Keymaps
-- ============================================================

-- terminal
vim.keymap.set("n", "<leader>\\", function()
  require("snacks").terminal()
end, { desc = "Toggle a terminal" })

-- zen
vim.keymap.set("n", "<leader>z", function()
  require("snacks").zen()
end, { desc = "Toggle Zen Mode" })

vim.keymap.set("n", "<leader>Z", function()
  require("snacks").zen.zoom()
end, { desc = "Toggle Zoom" })

-- scratch
vim.keymap.set("n", "<leader>.", function()
  require("snacks").scratch()
end, { desc = "Toggle Scratch Buffer" })

vim.keymap.set("n", "<leader>S", function()
  require("snacks").scratch.select()
end, { desc = "Select Scratch Buffer" })

-- notifier
vim.keymap.set("n", "<leader>nh", function()
  require("snacks").notifier.show_history()
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>un", function()
  require("snacks").notifier.hide()
end, { desc = "Dismiss All Notifications" })

-- bufdelete
vim.keymap.set("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Delete Buffer" })

-- rename
vim.keymap.set("n", "<leader>cR", function()
  require("snacks").rename.rename_file()
end, { desc = "Rename File" })

-- gitbrowse
vim.keymap.set({ "n", "v" }, "<leader>gcf", function()
  require("snacks").gitbrowse()
end, { desc = "Git Browse" })

-- git
vim.keymap.set("n", "<leader>gb", function()
  require("snacks").git.blame_line()
end, { desc = "Git Blame Line" })

-- lazygit
vim.keymap.set("n", "<leader>lg", function()
  require("snacks").lazygit()
end, { desc = "Lazygit" })

vim.keymap.set("n", "<leader>gf", function()
  require("snacks").lazygit.log_file()
end, { desc = "Lazygit Current File History" })

vim.keymap.set("n", "<leader>gl", function()
  require("snacks").lazygit.log()
end, { desc = "Lazygit Log (cwd)" })

-- picker
vim.keymap.set("n", "<leader>pp", function()
  require("snacks").picker.smart({ multi = { "buffers", "files" } })
end, { desc = "Smart Picker" })

vim.keymap.set("n", "<leader>pf", function()
  require("snacks").picker.files()
end, { desc = "Files Picker" })

vim.keymap.set("n", "<leader>pe", function()
  require("snacks").picker.buffers()
end, { desc = "Buffers Picker" })

vim.keymap.set("n", "<leader>pg", function()
  require("snacks").picker.grep()
end, { desc = "Grep Picker" })

vim.keymap.set("n", "<leader>ph", function()
  require("snacks").picker.help()
end, { desc = "Help Picker" })

vim.keymap.set("n", "<leader>ps", function()
  require("snacks").picker.git_status()
end, { desc = "Git Status Picker" })

vim.keymap.set("n", "<leader>:", function()
  require("snacks").picker.command_history()
end, { desc = "Command history picker" })

-- Grep across immediate subdirectories of cwd.
-- Useful when the root directory contains multiple git repositories.
vim.keymap.set("n", "<leader>pG", function()
  local cwd = vim.fn.getcwd()
  local glob_results = vim.fn.glob(cwd .. "/*", 0, 1)
  local dirs = {}
  local skip = { ["node_modules"] = true, [".git"] = true, ["target"] = true, ["build"] = true }

  for _, p in ipairs(glob_results) do
    if vim.fn.isdirectory(p) == 1 then
      local basename = vim.fn.fnamemodify(p, ":t")
      if not skip[basename] then
        table.insert(dirs, p)
      end
    end
  end

  if #dirs == 0 then dirs = { cwd } end

  require("snacks").picker.grep({
    dirs = dirs,
    live = true,
    need_search = true,
    show_empty = true,
  })
end, { desc = "Grep Picker sub-repositories" })

-- Find files across immediate subdirectories of cwd.
vim.keymap.set("n", "<leader>pF", function()
  local cwd = vim.fn.getcwd()
  local entries = vim.fn.glob(cwd .. "/*", 0, 1)
  local dirs = {}
  local skip = {
    ["node_modules"] = true, [".git"] = true, ["target"] = true,
    ["build"] = true, ["dist"] = true,
  }

  for _, p in ipairs(entries) do
    if vim.fn.isdirectory(p) == 1 then
      local name = vim.fn.fnamemodify(p, ":t")
      if not skip[name] then
        table.insert(dirs, p)
      end
    end
  end

  if #dirs == 0 then dirs = { cwd } end

  require("snacks").picker.files({
    dirs = dirs,
    hidden = false,
    ignored = false,
    follow = false,
    show_empty = true,
  })
end, { desc = "Find files sub-repositories (auto-detect subdirs)" })

-- Open a plugin config file directly
vim.keymap.set("n", "<leader>rp", function()
  local plugins_dir = vim.fn.expand("~/.config/nvim/lua/plugins")
  local files = vim.fn.globpath(plugins_dir, "*.lua", false, true)
  local items = {}

  for _, f in ipairs(files) do
    local name = vim.fn.fnamemodify(f, ":t")
    if name:sub(-4) == ".lua" then
      name = name:sub(1, -5)
    end
    table.insert(items, name)
  end

  if #items == 0 then
    vim.schedule(function()
      local name = vim.fn.input("No plugin files found. Create new plugin (name): ")
      if name and name ~= "" then
        local path = plugins_dir .. "/" .. name
        if path:sub(-4) ~= ".lua" then path = path .. ".lua" end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end
    end)
    return
  end

  vim.ui.select(items, {
    prompt = "Plugins",
    fmt_item = function(item) return item end,
  }, function(choice)
    if not choice or choice == "" then return end
    local path = plugins_dir .. "/" .. choice
    if path:sub(-4) ~= ".lua" then path = path .. ".lua" end
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end)
end, { desc = "Find Plugins" })

-- ============================================================
-- Setup
-- ============================================================

require("snacks").setup({
  bigfile      = { enabled = true },
  indent       = { enabled = true },
  input        = { enabled = true },
  picker       = require("meta-plugins.snacks.picker"),
  notifier     = { enabled = true },
  quickfile    = { enabled = true },
  scroll       = { enabled = true },
  statuscolumn = { enabled = true },
  words        = { enabled = true },
  image = {
    enabled = true,
    doc = {
      inline     = false,
      float      = true,
      max_width  = 60,
      max_height = 30,
    },
  },
})
