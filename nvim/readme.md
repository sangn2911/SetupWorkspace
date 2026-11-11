## Neovim

Standalone config from `~/.config/nvim`. Copy this folder there.

```
nvim/
  init.lua
  nvim-pack-lock.json
  homura_setup.sh
  kitty.conf
  lua/config/options.lua
  lua/config/keymaps.lua
  lua/config/json.lua
  lua/plugins/init.lua
  lua/plugins/colorscheme.lua
  lua/plugins/telescope.lua
  lua/plugins/treesitter.lua
  lua/plugins/kulala.lua
```

Cursor vscode-neovim lives in `cursor/neovim/`, not here. Kulala is skipped when `vim.g.vscode` is set.

Leader is Space.

## Install

1. Copy this folder to `~/.config/nvim`
2. Run the apt / CLI steps in `homura_setup.sh` (ripgrep, fd-find, jq, tree-sitter 0.27, build-essential)
3. Merge `kitty.conf` into `~/.config/kitty/kitty.conf` so Ctrl+Enter and Ctrl+Alt chords reach Neovim
4. Restart Neovim so `vim.pack` installs plugins
5. `:TSInstall json go yaml lua` if highlighting is missing

Kulala HTTP client (Linux x86_64):

- Plugin is the public fork `andycowan/kulala.nvim`
- Build `kulala-core` with Bun (`bun run build:linux-x64`) and put the binary at `~/.local/share/nvim/kulala.nvim/bin/kulala-core`
- Clone `andycowan/tree-sitter-kulala-http`, build the parser into `~/.local/share/nvim/site/parser/kulala_http.so`

Package commands:

- Check update `:lua vim.pack.update()` then `:w` to apply, `:q` to discard
- Disable a plugin: comment its `vim.pack.add`, then `:restart`
- Remove: `:lua vim.pack.del({ "plugin-name" })`

## Options (`lua/config/options.lua`)

- Relative + absolute line numbers
- 2-space indent, expandtab
- Wrap off (Alt+Z toggles); `smoothscroll` on
- Clipboard `unnamedplus`
- Cursor: underline in normal, bar in insert

JSON buffers stay unfolded (`lua/config/json.lua`).

## Colors

- Installed: gruvbox, kanagawa, melange
- Active: **melange** (`lua/plugins/colorscheme.lua`)

## Shared keymaps (Neovim + vscode-neovim)

- `c` / `x` / `s` — delete/change without yanking
- `Ctrl+j` — Enter (insert)
- `Ctrl+a` — select all
- `Ctrl+s` / `Alt+s` — save
- `Ctrl+z` — undo (`Space Z` suspends Neovim)
- `Ctrl+Shift+z` — redo
- `Alt+z` — toggle wrap
- `Ctrl+Shift+j` / `Ctrl+Shift+k` — duplicate line below / above
- `Alt+j` / `Alt+k` — move line down / up
- `Alt+Shift+h` / `Alt+Shift+l` — jumplist back / forward (Ctrl+O / Ctrl+I)
- `Shift+Alt+F` — pretty-print JSON with jq (`json` / `jsonc`)

vscode-neovim also maps `]d` / `[d` to VS Code markers.

## Neovim-only keymaps

- `j` / `k` — screen-row motion when wrap is on
- `Ctrl+Alt+h/l/j/k` — resize the current split
- `Ctrl+Alt+d` — diagnostic float
- `Space ff` — find files (Telescope)
- `Space fr` — recent files
- `Space fg` — live grep (needs ripgrep)

## HTTP / kulala (`.http` / `.rest`)

REST Client files with newline query params (`?` / `&` on their own lines). Format with Shift+Alt+F so kulala-core sees an indented continuation.

- `Ctrl+Enter` — send the request under the cursor
- `Ctrl+Alt+E` — pick env (`dev` / `qc` / `local`); last choice is saved
- `Shift+Alt+F` — format `.http` (indent `?` / `&` / `# ?id=`, two blank lines between `###`)
- `Ctrl+Alt+Q` — close the response split
- `Ctrl+Alt+P` — toggle request / response (`gb` also returns to the `.http` file)
- `Ctrl+Alt+D` — diagnostic under cursor
- `]e` / `[e` — next / previous HTTP LSP error
- `K` — hover resolved `{{variable}}`
- `Space Ri` — inspect resolved request
- `Space Rr` — replay last request
- `Space Rt` — toggle body / headers
- `Space Rf` — same format as Shift+Alt+F

Response headers: name (left of `:`) red, value white, status line (no `:`) red.

Env file: `database/rest_client/http-client.env.json` (not `.vscode/settings.json`). Default env is `dev`. Gzip JSON is gunzipped before the body pane; prefer `Accept-Encoding: identity`.

## Kitty (`kitty.conf`)

Linux TTY does not send Ctrl+Enter / Ctrl+Alt as distinct keys unless Kitty uses CSI u:

- `ctrl+enter`
- `ctrl+alt+e/q/h/l/j/k/d/p/f`
- `shift+alt+f`

Also: underline cursor, font size 15, no window decorations.

Background `#2d2a2e` and foreground `#fcfcfa` match Cursor Monokai Pro. `background_opacity 0.85` (live tweak with `kitty @ set-background-opacity`).

Tabs: `Alt+1` … `Alt+8` switch tabs (`Alt+9` left for the OS). Bar `#403e41`, font 12pt, active title `#c1c0c0`, inactive title `#727072`.
