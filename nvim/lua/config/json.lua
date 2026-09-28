-- Editor behavior, not a plugin: keep JSON files fully expanded when opened in Neovim.
-- Window-local fold options are set on FileType and BufWinEnter so they stick after splits.

local function unfold_json()
  vim.wo.foldenable = false
  vim.wo.foldmethod = "manual"
  vim.wo.foldlevel = 99
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = unfold_json,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "json" or ft == "jsonc" then
      unfold_json()
    end
  end,
})
