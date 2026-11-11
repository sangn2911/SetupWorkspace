-- Editor behavior, not plugins: line numbers, indentation, clipboard, and cursor.
-- The active colorscheme is set in lua/plugins/colorscheme.lua.

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

-- Netrw replaces buffer options; nu/rnu here so Explore shows relative numbers.
vim.g.netrw_bufsettings = "noma nomod nu rnu nowrap ro nobl"

vim.cmd.filetype("plugin", "indent", "on")
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Do not wrap long lines; scroll horizontally instead.
-- Alt+Z toggles wrap. smoothscroll then moves by screen row, so a long JSON
-- value can sit above the next field instead of jumping the whole line away.
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.textwidth = 0
vim.opt.formatoptions:remove("t")
vim.opt.smoothscroll = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Cursor
vim.opt.guicursor = "n-v-sm:hor20,i-ci-ve-r-cr:ver25"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Cursor
vim.opt.guicursor = "n-v-sm:hor20,i-ci-ve-r-cr:ver25"
