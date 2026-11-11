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

-- Drop the editor fill so Kitty's transparent background shows through.
local function clear_editor_bg()
  for _, group in ipairs({
    "Normal",
    "NormalNC",
    "NormalFloat",
    "SignColumn",
    "EndOfBuffer",
    "LineNr",
    "FoldColumn",
  }) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE" })
  end
end
clear_editor_bg()
vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_editor_bg })
