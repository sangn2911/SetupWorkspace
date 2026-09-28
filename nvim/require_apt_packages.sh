# Commands to run once for Telescope and Tree-sitter.
# Plugin URLs are already in init.lua. This file is the system and Neovim steps.

# Telescope
# 1. Install ripgrep. Space fg (live_grep) searches file text with rg.
sudo apt install ripgrep
# 2. Install fd. Debian's binary is fdfind, not fd. Telescope file search still works without it.
sudo apt install fd-find
# 3. Restart Neovim so vim.pack installs plenary.nvim and telescope.nvim.
#    :w | restart
# 4. No further command. Keys:
#    Space ff  files under the folder where Neovim was started
#    Space fr  recent files
#    Space fg  text search in that same folder

# Tree-sitter
# Apt tree-sitter-cli is 0.22. nvim-treesitter needs 0.26.1 or newer.
# 1. Install the compiler and download tools used when a parser is built.
sudo apt install build-essential curl tar
# 2. Install CLI 0.27 into ~/.local/bin so it is used instead of /usr/bin/tree-sitter.
curl -fsSL -o /tmp/tree-sitter.gz https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.0/tree-sitter-linux-x64.gz
gunzip -c /tmp/tree-sitter.gz > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter
# 3. Confirm the new CLI. The version must be 0.27.0, not 0.22.6.
tree-sitter --version
# 4. Restart Neovim so vim.pack installs nvim-treesitter.
#    :w | restart
# 5. Inside Neovim, install parsers. Highlighting starts on the next file open.
#    :TSInstall json go yaml lua
# 6. Later, refresh parsers after a plugin update.
#    :TSUpdate

# JSON format keys in init.lua (Space jp, jm, js, jv)
sudo apt install jq
