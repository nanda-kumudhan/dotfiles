# Neovim Guide

This config uses LazyVim. The leader key is `Space`.

The most useful built-in help is interactive:

- Press `Space` and wait to see available key groups.
- Press `Space ?` to search mappings for the current buffer.
- Press `Space s k` to search every active keymap.
- Press `Space f h` to reopen this guide.
- Run `:checkhealth` when diagnosing a problem.

## Sway-Style Controls

Sway captures the `Super` key before terminal applications can receive it, so
Neovim uses `Alt` as its equivalent modifier.

| Sway-style key | Neovim action |
| --- | --- |
| `Alt-Arrow` | Focus the window in that direction |
| `Alt-Shift-Arrow` | Move the current window in that direction |
| `Alt-h` / `Alt-v` | Create a horizontal / vertical split |
| `Alt-f` | Maximize or restore the current window |
| `Alt-q` | Close the current buffer |
| `Alt-+` / `Alt--` | Grow / shrink the current window |
| `Alt-1` through `Alt-9` | Switch to that numbered buffer |

These work in Normal mode. Standard Vim and LazyVim mappings remain available.

## First Steps

Neovim is modal:

| Key | Action |
| --- | --- |
| `i` | Insert before the cursor |
| `a` | Insert after the cursor |
| `o` / `O` | Open a line below / above |
| `Esc` | Return to Normal mode |
| `v` / `V` | Select characters / lines |
| `:` | Enter a command |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `.` | Repeat the last edit |

Use `h j k l` to move left, down, up, and right. Prefix commands with a
number, such as `5j`, to repeat them.

Useful editing motions:

| Key | Action |
| --- | --- |
| `w` / `b` | Next / previous word |
| `0` / `^` / `$` | Line start / first text / line end |
| `gg` / `G` | First / last line |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up |
| `%` | Matching bracket |
| `f<char>` / `t<char>` | Find / move before a character on this line |
| `*` / `#` | Search word forward / backward |

Operators combine with motions:

| Example | Action |
| --- | --- |
| `dd` / `yy` | Delete / copy a line |
| `dw` / `yw` | Delete / copy to the next word |
| `ciw` | Replace the current word |
| `di"` / `ci"` | Delete / replace inside quotes |
| `dap` / `yap` | Delete / copy a paragraph |
| `p` / `P` | Paste after / before |
| `gcc` | Toggle comment on a line |
| `gc` in Visual mode | Toggle comments on the selection |
| `>` / `<` in Visual mode | Indent / unindent |
| `Alt-j` / `Alt-k` | Move line or selection down / up |

## Dashboard

Start Neovim with `nvim` to show the dashboard.

| Key | Action |
| --- | --- |
| `n` | New file |
| `f` | Find file |
| `g` | Search text in the project |
| `r` | Recent files |
| `p` | Projects |
| `c` | Neovim config files |
| `h` | This guide |
| `l` | Plugin manager |
| `q` | Quit |

Open the dashboard later with `Space f d`.

## Files And Search

| Key | Action |
| --- | --- |
| `Ctrl-p` or `Space Space` | Find project file |
| `Ctrl-e` or `Space e` | File explorer |
| `Ctrl-f` or `Space s b` | Search lines in current file |
| `Ctrl-Shift-f` or `Space /` | Search text in project |
| `Space f f` | Find project file |
| `Space f F` | Find file from current directory |
| `Space f r` | Recent files |
| `Space f p` | Projects |
| `Space f c` | Search Neovim config |
| `Space ,` | Open-buffer picker |
| `Space s w` | Search word under cursor or selection |
| `Space s d` | Search workspace diagnostics |
| `Space s k` | Search keymaps |
| `Space s h` | Search help pages |
| `Space s R` | Resume the previous picker |

Picker controls:

| Key | Action |
| --- | --- |
| `Enter` | Open selection |
| `Ctrl-s` / `Ctrl-v` | Open in horizontal / vertical split |
| `Ctrl-t` | Open in a new tab |
| `Ctrl-j` / `Ctrl-k` | Move down / up |
| `Esc` | Close picker |

In the explorer, use `Enter` to open, `a` to add, `d` to delete, `r` to
rename, `y` to copy, `p` to paste, and `?` for all explorer keys.

## Saving, Buffers, Windows

| Key | Action |
| --- | --- |
| `Ctrl-s` | Save |
| `Ctrl-q` | Close the current window, confirming changes |
| `Space q q` | Quit all |
| `Shift-h` / `Shift-l` | Previous / next buffer |
| `Space b d` | Close current buffer |
| `Space b o` | Close other buffers |
| `Space b b` | Switch to previous buffer |
| `Space -` | Split below |
| `Space \|` | Split right |
| `Ctrl-h/j/k/l` | Move between windows |
| `Ctrl-arrow` | Resize current window |
| `Space w d` | Close window |
| `Space w m` | Maximize / restore window |

Tabs:

| Key | Action |
| --- | --- |
| `Space Tab Tab` | New tab |
| `Space Tab ]` / `Space Tab [` | Next / previous tab |
| `Space Tab d` | Close tab |
| `Space Tab o` | Close other tabs |

## Code And LSP

These mappings appear when a language server is attached:

| Key | Action |
| --- | --- |
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | Hover documentation |
| `gK` | Signature help |
| `Space c a` | Code action |
| `Space c r` | Rename symbol |
| `Space c f` | Format file or selection |
| `Space c d` | Diagnostics for current line |
| `Space c l` | LSP information |
| `Space c s` | Document symbols |
| `Space s S` | Workspace symbols |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `]w` / `[w` | Next / previous warning |
| `Space x x` | Workspace diagnostics panel |
| `Space x X` | Current-buffer diagnostics panel |

Completion appears automatically in Insert mode:

| Key | Action |
| --- | --- |
| `Ctrl-n` / `Ctrl-p` | Next / previous suggestion |
| `Enter` | Accept selected suggestion |
| `Ctrl-space` | Open completion manually |
| `Ctrl-e` | Hide completion |
| `Tab` / `Shift-Tab` | Move through snippet fields |

Language servers and tools are managed with `Space c m` (`:Mason`).

## Git

| Key | Action |
| --- | --- |
| `Space g s` | Git status picker |
| `Space g d` | Changed hunks |
| `Space g l` | Repository log |
| `Space g f` | Current-file history |
| `Space g b` | Blame current line |
| `]h` / `[h` | Next / previous changed hunk |
| `Space g h p` | Preview hunk |
| `Space g h s` | Stage hunk |
| `Space g h r` | Reset hunk |
| `Space g h b` | Blame line |

`Space g g` opens Lazygit when the `lazygit` command is installed.

## Terminal And Sessions

| Key | Action |
| --- | --- |
| `Ctrl-/` | Toggle project terminal |
| `Space f t` | Project-root terminal |
| `Space f T` | Current-directory terminal |
| `Ctrl-/` in terminal | Hide terminal |
| `Space q s` | Restore current-directory session |
| `Space q l` | Restore last session |
| `Space q S` | Select a session |

Use `Ctrl-h/j/k/l` to leave a terminal and move to another window.

## Markdown, LaTeX, And Java

Markdown:

- `Space m t` toggles rendered Markdown.
- `Space c f` formats Markdown with Prettier when installed.

LaTeX through VimTeX:

- `\ll` starts or stops compilation.
- `\lv` opens the PDF viewer.
- `\lk` stops compilation.
- `\le` shows errors.
- Run `:VimtexInfo` for project status.

The VimTeX local leader is `\`, not `Space`.

Java:

- Opening a Maven or Gradle project starts `jdtls`.
- `Space c o` organizes imports.
- `Space c x v` extracts a variable.
- `Space c x c` extracts a constant.
- Select code then use `Space c x m` to extract a method.
- `Space t t` runs the Java test class when Java debug/test tools are installed.
- `Space t r` runs the nearest Java test.

Install missing Java tools from `Space c m`.

## UI And Maintenance

| Key | Action |
| --- | --- |
| `Space u w` | Toggle wrapping |
| `Space u s` | Toggle spelling |
| `Space u l` | Toggle line numbers |
| `Space u L` | Toggle relative numbers |
| `Space u d` | Toggle diagnostics |
| `Space u h` | Toggle inlay hints |
| `Space u g` | Toggle indent guides |
| `Space u z` | Zen mode |
| `Space l` | Lazy plugin manager |
| `Space c m` | Mason tool manager |

Useful commands:

| Command | Action |
| --- | --- |
| `:Lazy` | Install, update, or inspect plugins |
| `:Lazy sync` | Synchronize plugins with the lockfile |
| `:Mason` | Manage language servers and formatters |
| `:LspInfo` | Inspect active language servers |
| `:ConformInfo` | Inspect formatters |
| `:checkhealth` | Check Neovim and plugin health |
| `:messages` | Show message history |
