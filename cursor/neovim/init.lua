-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Cursor
vim.opt.guicursor = {
    "n-v-c:hor25",
    "i-ci-ve:ver25",
    "r-cr:ver25",
    "o:ver25",
}

-- Insert mode
vim.keymap.set("i", "<C-j>", "<CR>", { noremap = true })

-- Delete/change without yanking
vim.keymap.set({ "n", "x", "o" }, "c", '"_c', { noremap = true })
vim.keymap.set({ "n", "x", "o" }, "x", '"_x', { noremap = true })
vim.keymap.set({ "n", "x", "o" }, "s", '"_s', { noremap = true })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })

-- VS Code actions
local vscode = require("vscode")

vim.keymap.set("n", "]d", function()
    vscode.action("editor.action.marker.nextInFiles")
end)

vim.keymap.set("n", "[d", function()
    vscode.action("editor.action.marker.prevInFiles")
end)