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
  pickers = {
    -- Hidden + skip .gitignore so .env shows. .fdignore / .ignore still apply.
    find_files = {
      hidden = true,
      find_command = { "fdfind", "--type", "f", "--hidden", "--no-ignore-vcs" },
    },
    -- Same for live_grep: .rgignore / .ignore still apply.
    live_grep = {
      additional_args = { "--hidden", "--no-ignore-vcs" },
    },
  },
})

-- Search file in current directory nvim open
vim.keymap.set("n", "<leader>ff", builtin.find_files)
-- Search recent file
vim.keymap.set("n", "<leader>fr", builtin.oldfiles)
-- Search text across folder nvim open
vim.keymap.set("n", "<leader>fg", builtin.live_grep)

-- live_grep_glob asks for a file glob first so the word search is limited to matching paths.
local function live_grep_glob()
  local glob = vim.fn.input("glob: ")
  builtin.live_grep({
    glob_pattern = glob ~= "" and glob or nil,
  })
end
vim.keymap.set("n", "<leader>fG", live_grep_glob, { desc = "Live grep with file glob" })
