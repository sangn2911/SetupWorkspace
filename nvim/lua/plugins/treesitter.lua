-- Tree-sitter syntax highlight.
-- Neovim already ships default parsers (lua, vim, vimdoc, query, markdown, c, …).
-- Extra parsers come from nvim-treesitter. Add a name to extra_parsers, then restart.
-- Install later with :TSInstall <lang> or by appending to extra_parsers.

local extra_parsers = {
  "go",
}

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

require("nvim-treesitter").setup()
require("nvim-treesitter").install(extra_parsers)

-- Highlight only when a parser exists: bundled defaults, extra_parsers, or :TSInstall.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
