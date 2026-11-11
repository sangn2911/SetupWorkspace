# VS Code setup

The settings, keybindings, and extension inventories were captured on 2026-11-11.

| Repository path | Restore location |
| --- | --- |
| `settings.json`, `keybindings.json` | Default profile's `User/` folder |
| `profiles/code_db/` | The `code_db` profile |
| `profiles/code_go/` | The `code_go` profile |
| `argv.json` | The file opened by **Preferences: Configure Runtime Arguments** |

On Linux, the regular install uses `~/.config/Code/User/`. The portable install uses `data/user-data/User/` beside the application files.

1. Create the named profiles in the Profiles editor. Open **Preferences: Open User Settings (JSON)** in each profile to locate its settings folder.
2. Quit VS Code and copy each profile's settings and keybindings into the corresponding folder. Restore `argv.json` to the location identified above.
3. Install the extensions from the matching `extensions.txt`. For example, run `code --profile code_go --install-extension publisher.extension@version`. For the default profile, omit `--profile`. See [extension.md](extension.md) for the bundled VSIX files.
4. Review machine-specific paths in the restored settings.

The settings include VSCodeVim mappings under `vim.visualModeKeyBindingsNonRecursive` that let you change or delete text without replacing the clipboard contents.
