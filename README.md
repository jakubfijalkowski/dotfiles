.dotfiles
=========

Nothing fancy, just a couple of .files that I use on **Arch Linux** with a
Hyprland/Wayland desktop. All configured so that I can abuse my
[ErgoDox EZ](https://configure.ergodox-ez.com/ergodox-ez/layouts/B47Rx/latest/0)
keyboard.

Notable software used by this config:

 1. [Hyprland](config/hypr/hyprland.conf) - the compositor, configured in Lua
    (not hyprlang) via [`conf/`](config/hypr/conf), plus hyprlock/hypridle.
 2. [QuickShell](config/quickshell) - the status bar, drawers and notification
    toasts (QML).
 3. [zsh](zshrc) - [zsh4humans](https://github.com/romkatv/zsh4humans/blob/master/.zshrc)
    + [powerlevel10k](https://github.com/romkatv/powerlevel10k), with the
    modules in [`zsh/`](zsh).
 4. [Neovim](config/nvim/init.lua) - lazy.nvim and the native LSP client.
 5. [Ghostty](config/ghostty/config) as the terminal.
 6. [walker](config/walker/config.toml) as the launcher.

## Layout

| Path | Goes to | What |
|---|---|---|
| [`config/`](config) | `~/.config/` | hypr, quickshell, nvim, ghostty, walker, wpaperd, satty, bat, fontconfig, uwsm, Code |
| [`zsh/`](zsh), [`zshrc`](zshrc) | `~/.zsh/`, `~/.zshrc` | shell config; `~/.local/zshrc` holds per-machine overrides (untracked) |
| [`scripts/`](scripts) | `~/.local/bin/` | helpers referenced by the bar and keybinds |
| [`etc/`](etc) | `/etc/` | system files (pacman, systemd-networkd, sddm, pam, udev, iwd) |
| [`packages/`](packages) | - | pacman/AUR manifests (`base`, `aur`, `amd`) - mostly unmaintained |

The user config is **symlinked** into this repo, so editing a file here edits
the running config directly - most stacks pick the change up on save. The
`etc/` files are copies and have to be put in place again after a change.
