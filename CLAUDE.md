# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal **Arch Linux** dotfiles for a Hyprland/Wayland desktop. There is no
build, no test suite, and no application to run — the "code" here is
configuration. Notable stacks: Hyprland (compositor), a QuickShell status bar,
Neovim, and zsh (zsh4humans + powerlevel10k).

## Sub-project CLAUDE.md files — read the local one first

Three areas carry their own `CLAUDE.md` with rules that **override** this file
for work inside them. When a task touches one of these, read (load) that file
before editing — it is the source of truth for that stack:

- `config/quickshell/CLAUDE.md` — the QuickShell bar (QML): theming, drawers,
  notifications, hot-reload, and the do → screenshot → undo testing loop.
- `config/hypr/CLAUDE.md` — the Hyprland config (Lua via the `hl` table, **not**
  hyprlang). Insists on reading the live API stubs/wiki before every edit.
- `config/nvim/CLAUDE.md` — the Neovim config (lazy.nvim, native LSP): targets
  latest Neovim, prefers native APIs and cutting-edge plugins.

## Deployment model — the repo *is* the live config

Files are **symlinked into this repo** rather than copied out. A symlink may be
a whole directory (`~/.config/quickshell` → `config/quickshell`,
`~/.config/hypr/conf` → `config/hypr/conf`) or a single file (`~/.zshrc` →
`zshrc`, `~/.local/bin/check-updates` → `scripts/check-updates`). Consequences:

- Editing a repo file edits the running config directly — no install/sync step.
- There is **no install script tracked in the repo**; symlinks were created by
  hand. Do not assume every repo file is currently linked — verify with `ls -l`
  on the target before relying on a change being live.
- Most stacks pick up changes on save (Hyprland reloads, QuickShell hot-reloads,
  zsh on new shell). See the sub-project file for the reload rule.

## Directory map

| Path | Symlinks to | Notes |
|---|---|---|
| `config/` | `~/.config/` | quickshell, hypr, nvim (each with its own CLAUDE.md), plus bat, ghostty, walker, wpaperd, satty, fontconfig, systemd, uwsm, Code |
| `zsh/`, `zshrc` | `~/.zsh/`, `~/.zshrc` | `zshrc` sources the `zsh/*.zsh` modules; `~/.local/zshrc` holds per-machine overrides (untracked) |
| `scripts/` | `~/.local/bin/` | `check-updates`, `yubikey-touch-status`, `unblock-docker-bridge` — referenced by the bar and keybinds |
| `etc/` | `/etc/` | system files (pacman, systemd-networkd, sddm, pam, udev, iwd) — editing these needs **root**, and they are not hot-reloaded |
| `packages/` | — | pacman/AUR package manifests: `base` (explicit repo pkgs), `aur`, `amd`. Kept in sync with what's installed |
| `gitconfig`, `gnupg/`, `fdignore` | `~/.gitconfig`, `~/.gnupg/`, … | misc dotfiles |

## Conventions

- **Commits are short, imperative, and scope-prefixed**: `scope: summary`, where
  the scope is the area touched — `quickshell:`, `hypr:`, `nvim:`, `zsh:`,
  `packages:`, `etc:`, `scripts:`. Keep the summary to one terse line.
- **Commits are GPG-signed** (`commit.gpgsign = true`) — a commit may block on a
  pinentry passphrase prompt that only the user can answer. Commit/push only when
  asked.
- **Formatting** repo-wide is set by `.editorconfig`: UTF-8, LF, 2-space indent,
  final newline, trimmed trailing whitespace. Lua (nvim + hypr) is additionally
  formatted with **stylua** — it is not on `PATH`; use the mason binary at
  `~/.local/share/nvim/mason/bin/stylua`. Syntax-check Lua with `luac -p <file>`.
