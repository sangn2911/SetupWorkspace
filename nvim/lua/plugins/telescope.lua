-- Telescope finds files, recent files, and text in the folder where Neovim was started.
-- plenary.nvim is the library Telescope requires.

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
})

local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    initial_mode = "insert",
  },
})

-- Search file in current directory nvim open
vim.keymap.set("n", "<leader>ff", builtin.find_files)
-- Search recent file
vim.keymap.set("n", "<leader>fr", builtin.oldfiles)
-- Search text across folder nvim open
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
