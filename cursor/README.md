# Cursor setup

The user configuration and extension inventory were captured on 2026-11-11.

| Repository path | Restore location |
| --- | --- |
| `settings.json`, `keybindings.json` | `~/.config/Cursor/User/` on Linux |
| `argv.json` | `~/.cursor/argv.json` |
| `rules/`, `skills/` | `~/.cursor/rules/`, `~/.cursor/skills/` |
| `mcp.example.json` | `~/.cursor/mcp.json`, after filling in the local values |

1. Quit Cursor and copy the settings, keybindings, runtime arguments, rules, and skills to their restore locations.
2. Install the extensions listed in `extensions.txt`.
3. If you use MCP, fill in the Atlassian placeholders locally and review the gopls workspace paths, Go toolchain paths, and required executables.
4. In Cursor Settings → Rules → User Rules, remove any entries that duplicate the installed rules or skills.

`code_style_rules.mdc` is always applied. `work-task.mdc` applies to files matching `.general/tasks/**/*.md`. In Agent chat, type `/` to select a skill.

The `vim/` and `neovim/` folders contain alternate configurations. The shared and backup keybinding files are available for reference.
