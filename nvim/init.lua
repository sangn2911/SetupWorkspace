-- ## Overview Structure ##
-- config.options — numbers, indent, clipboard, cursor
-- config.keymaps — global maps, wrap, duplicate/move lines, undo/redo, jumps, VS Code markers, JSON pretty-print
-- config.json — keep JSON buffers fully expanded
-- plugins.colorscheme — gruvbox, kanagawa, melange. Active colorscheme is melange.
-- plugins.telescope — find files, recent files, and text search (needs plenary)
-- plugins.treesitter — Neovim bundled parsers plus extra_parsers (go); add names in lua/plugins/treesitter.lua
-- plugins.kulala — send .http requests (reads VS Code REST Client env vars)

-- ## Update vim packages ##
-- Check update :lua vim.pack.update()
-- Apply update => :w
-- Discard update => :q

-- ## Manage packages (enable/disable, remove) ##
-- Enable => uncomment its vim.pack.add in lua/plugins, then :luafile that file
-- Disable => comment out its vim.pack.add, then :restart
-- Remove => disable it, then :lua vim.pack.del({ "plugin-name" })

-- Leader must be set before plugin and keymap modules load.
vim.g.mapleader = " "

require("config.options")
require("plugins")
require("config.keymaps")
require("config.json")

