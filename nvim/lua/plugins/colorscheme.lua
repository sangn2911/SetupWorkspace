-- Theme plugins. gruvbox, kanagawa, and melange are installed here.
-- Active colorscheme is melange. Switch by uncommenting another scheme below.

vim.pack.add({
  "https://github.com/ellisonleao/gruvbox.nvim",
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/savq/melange-nvim",
})

-- require("kanagawa").setup()
-- vim.cmd.colorscheme("kanagawa-dragon")
-- vim.cmd.colorscheme("gruvbox")
vim.cmd.colorscheme("melange")
