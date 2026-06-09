local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })
map({ "n", "i", "v" }, "<C-q>", "<cmd>confirm quit<cr>", { desc = "Quit" })
map({ "n", "i", "v" }, "<C-p>", function()
  Snacks.picker.files({ hidden = true })
end, { desc = "Find file" })
map({ "n", "i", "v" }, "<C-e>", function()
  Snacks.explorer()
end, { desc = "File explorer" })
map({ "n", "i", "v" }, "<C-S-f>", function()
  Snacks.picker.grep()
end, { desc = "Search project" })
map("n", "<C-f>", function()
  Snacks.picker.lines()
end, { desc = "Find in file" })

-- Sway-style window controls. Super is handled by Sway, so Alt is used here.
map("n", "<A-Left>", "<C-w>h", { desc = "Focus left window" })
map("n", "<A-Down>", "<C-w>j", { desc = "Focus lower window" })
map("n", "<A-Up>", "<C-w>k", { desc = "Focus upper window" })
map("n", "<A-Right>", "<C-w>l", { desc = "Focus right window" })

map("n", "<A-S-Left>", "<C-w>H", { desc = "Move window left" })
map("n", "<A-S-Down>", "<C-w>J", { desc = "Move window down" })
map("n", "<A-S-Up>", "<C-w>K", { desc = "Move window up" })
map("n", "<A-S-Right>", "<C-w>L", { desc = "Move window right" })

map("n", "<A-h>", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<A-v>", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<A-f>", function()
  Snacks.zen.zoom()
end, { desc = "Maximize window" })
map("n", "<A-q>", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })
map("n", "<A-=>", "<cmd>vertical resize +4<cr>", { desc = "Grow window width" })
map("n", "<A-->", "<cmd>vertical resize -4<cr>", { desc = "Shrink window width" })

for index = 1, 9 do
  map("n", "<A-" .. index .. ">", "<cmd>BufferLineGoToBuffer " .. index .. "<cr>", {
    desc = "Switch to buffer " .. index,
  })
end

map("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Explorer" })
map("n", "<leader>fp", function()
  Snacks.picker.projects()
end, { desc = "Projects" })
map("n", "<leader>fd", function()
  Snacks.dashboard.open()
end, { desc = "Dashboard" })
map("n", "<leader>fh", function()
  vim.cmd.edit(vim.fn.stdpath("config") .. "/README.md")
end, { desc = "Neovim guide" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
