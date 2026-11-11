-- Editor behavior, not plugins: global keymaps.
-- Shared maps run in both standalone Neovim and vscode-neovim.
-- VS Code and Neovim each get their own wrap, duplicate, move, and jump actions.
-- JSON pretty-print is buffer-local on json and jsonc.

-- Insert mode: <C-j> is Enter. Duplicate uses <C-S-j> / <C-S-k>.
vim.keymap.set("i", "<C-j>", "<CR>", { noremap = true })

-- Delete/change without yanking
vim.keymap.set({ "n", "x", "o" }, "c", '"_c', { noremap = true })
vim.keymap.set({ "n", "x", "o" }, "x", '"_x', { noremap = true })
vim.keymap.set({ "n", "x", "o" }, "s", '"_s', { noremap = true })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })

-- Save file
vim.keymap.set({ "n", "i" }, "<C-s>", "<Cmd>write<CR>", { noremap = true })
vim.keymap.set({ "n", "i" }, "<M-s>", "<Cmd>write<CR>", { noremap = true })

-- <C-z> was suspend. Undo; redo is <C-S-z>; suspend is Space Z.
vim.keymap.set("n", "<C-z>", "u", { noremap = true, desc = "Undo" })
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, desc = "Undo" })
vim.keymap.set("x", "<C-z>", "<Esc>u", { noremap = true, desc = "Undo" })
vim.keymap.set("n", "<C-S-z>", "<C-r>", { noremap = true, desc = "Redo" })
vim.keymap.set("i", "<C-S-z>", "<C-o><C-r>", { noremap = true, desc = "Redo" })
vim.keymap.set("x", "<C-S-z>", "<Esc><C-r>", { noremap = true, desc = "Redo" })

-- Pretty-print the current JSON buffer with jq.
local function jq_buffer(args)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local result = vim.system({ "jq", unpack(args) }, { stdin = table.concat(lines, "\n") }):wait()
  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { trimempty = true }))
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true }
    vim.keymap.set("n", "<M-S-f>", function() jq_buffer({ "." }) end, vim.tbl_extend("force", opts, { desc = "Pretty-print JSON" }))
    -- vim.keymap.set("n", "<leader>jp", function() jq_buffer({ "." }) end, vim.tbl_extend("force", opts, { desc = "Pretty-print JSON" }))
    -- vim.keymap.set("n", "<leader>jm", function() jq_buffer({ "-c", "." }) end, vim.tbl_extend("force", opts, { desc = "Minify JSON" }))
    -- vim.keymap.set("n", "<leader>js", function() jq_buffer({ "-S", "." }) end, vim.tbl_extend("force", opts, { desc = "Sort JSON keys" }))
    -- vim.keymap.set("n", "<leader>jv", function() jq_buffer({ "empty" }) end, vim.tbl_extend("force", opts, { desc = "Validate JSON" }))
  end,
})

if vim.g.vscode then
  local vscode = require("vscode")

  -- Toggle wrap (VS Code Alt+Z)
  vim.keymap.set({ "n", "i", "x" }, "<M-z>", function()
    vscode.action("editor.action.toggleWordWrap")
  end, { desc = "Toggle wrap" })

  -- Duplicate line below / above (<C-S-j> / <C-S-k>)
  vim.keymap.set({ "n", "i", "x" }, "<C-S-j>", function()
    vscode.action("editor.action.copyLinesDownAction")
  end, { desc = "Duplicate line below" })

  vim.keymap.set({ "n", "i", "x" }, "<C-S-k>", function()
    vscode.action("editor.action.copyLinesUpAction")
  end, { desc = "Duplicate line above" })

  -- Move line down / up
  vim.keymap.set({ "n", "i", "x" }, "<M-j>", function()
    vscode.action("editor.action.moveLinesDownAction")
  end, { desc = "Move line down" })

  vim.keymap.set({ "n", "i", "x" }, "<M-k>", function()
    vscode.action("editor.action.moveLinesUpAction")
  end, { desc = "Move line up" })

  -- Jump to older / newer cursor position (same as Ctrl+O / Ctrl+I)
  vim.keymap.set({ "n", "x" }, "<M-S-h>", function()
    vscode.action("workbench.action.navigateBack")
  end, { desc = "Jump to older cursor position" })

  vim.keymap.set({ "n", "x" }, "<M-S-l>", function()
    vscode.action("workbench.action.navigateForward")
  end, { desc = "Jump to newer cursor position" })

  -- VS Code markers
  vim.keymap.set("n", "]d", function()
    vscode.action("editor.action.marker.nextInFiles")
  end)

  vim.keymap.set("n", "[d", function()
    vscode.action("editor.action.marker.prevInFiles")
  end)
else
  -- line("v") and line(".") are the live visual range.
  -- '< '> stay on the previous selection until visual mode is left.
  local function visual_line_range()
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    return start_line, end_line
  end

  local function select_lines(start_line, end_line)
    vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))
  end

  -- Toggle wrap (VS Code Alt+Z)
  vim.keymap.set({ "n", "i", "x" }, "<M-z>", function()
    vim.wo.wrap = not vim.wo.wrap
  end, { desc = "Toggle wrap" })

  -- Screen-row motion when wrap is on, so j/k stay inside a long JSON value.
  vim.keymap.set({ "n", "x" }, "j", function()
    return (vim.v.count == 0 and vim.wo.wrap) and "gj" or "j"
  end, { expr = true, desc = "Down (screen line when wrap)" })
  vim.keymap.set({ "n", "x" }, "k", function()
    return (vim.v.count == 0 and vim.wo.wrap) and "gk" or "k"
  end, { expr = true, desc = "Up (screen line when wrap)" })

  -- Duplicate line below / above (<C-S-j> / <C-S-k>)
  -- Below is yy then p. Above is yy then P (paste before), not k then p.
  vim.keymap.set({ "n", "i" }, "<C-S-j>", function()
    vim.cmd("normal! yyp")
  end, { desc = "Duplicate line below" })

  vim.keymap.set("x", "<C-S-j>", function()
    local start_line, end_line = visual_line_range()
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
    vim.api.nvim_buf_set_lines(0, end_line, end_line, true, lines)
    select_lines(end_line + 1, end_line + #lines)
  end, { desc = "Duplicate line below" })

  vim.keymap.set({ "n", "i" }, "<C-S-k>", function()
    vim.cmd("normal! yyP")
  end, { desc = "Duplicate line above" })

  vim.keymap.set("x", "<C-S-k>", function()
    local start_line, end_line = visual_line_range()
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
    vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, true, lines)
    select_lines(start_line, start_line + #lines - 1)
  end, { desc = "Duplicate line above" })

  -- Move line down / up
  vim.keymap.set({ "n", "i" }, "<M-j>", function()
    vim.cmd("move .+1")
    vim.cmd("normal! ==")
  end, { desc = "Move line down" })

  vim.keymap.set({ "n", "i" }, "<M-k>", function()
    vim.cmd("move .-2")
    vim.cmd("normal! ==")
  end, { desc = "Move line up" })

  -- :move from visual fills '< '> for this selection. gv=gv reselects, indents, reselects.
  vim.keymap.set("x", "<M-j>", ":move '>+1<CR>gv=gv", { silent = true, desc = "Move line down" })
  vim.keymap.set("x", "<M-k>", ":move '<-2<CR>gv=gv", { silent = true, desc = "Move line up" })

  -- Jump to older / newer cursor position (same as Ctrl+O / Ctrl+I)
  vim.keymap.set({ "n", "x" }, "<M-S-h>", function()
    vim.api.nvim_feedkeys(vim.keycode("<C-o>"), "n", false)
  end, { desc = "Jump to older cursor position" })

  vim.keymap.set({ "n", "x" }, "<M-S-l>", function()
    vim.api.nvim_feedkeys(vim.keycode("<C-i>"), "n", false)
  end, { desc = "Jump to newer cursor position" })

  vim.keymap.set("n", "<leader>Z", "<Cmd>suspend<CR>", { desc = "Suspend Neovim" })

  -- Grow/shrink the current split (HTTP response pane or any window).
  vim.keymap.set("n", "<C-M-h>", "<Cmd>vertical resize -5<CR>", { desc = "Narrow window" })
  vim.keymap.set("n", "<C-M-l>", "<Cmd>vertical resize +5<CR>", { desc = "Widen window" })
  vim.keymap.set("n", "<C-M-j>", "<Cmd>resize +3<CR>", { desc = "Taller window" })
  vim.keymap.set("n", "<C-M-k>", "<Cmd>resize -3<CR>", { desc = "Shorter window" })

  -- Inspect the diagnostic under the cursor (kulala HTTP LSP and other servers).
  vim.keymap.set("n", "<C-M-d>", function()
    vim.diagnostic.open_float(nil, { focus = true, scope = "cursor" })
  end, { desc = "Show LSP diagnostic" })

  -- Open netrw in the current file's directory. Kitty sends Ctrl+Shift+E as CSI u.
  vim.keymap.set({ "n", "i" }, "<C-S-e>", "<Cmd>Explore<CR>", { desc = "Open netrw" })
  vim.keymap.set({ "n", "i" }, "<Esc>[101;6u", "<Cmd>Explore<CR>", { desc = "Open netrw" })

  -- netrw: a creates a file (%); A creates a folder (d). remap so netrw's maps run.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function(ev)
      local opts = { buffer = ev.buf, remap = true, silent = true }
      vim.keymap.set("n", "a", "%", vim.tbl_extend("force", opts, { desc = "Create file" }))
      vim.keymap.set("n", "A", "d", vim.tbl_extend("force", opts, { desc = "Create folder" }))
    end,
  })
end
