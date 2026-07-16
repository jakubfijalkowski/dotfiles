# QuickShell bar

A QuickShell (Wayland/Hyprland) status bar for the DP-1 monitor, styled as a
Catppuccin Mocha "Neon" outline look: dark translucent bar, pills that carry
their module's color in border and text, and popups that visually emerge from
their pill.

Runs with `qs` (config auto-discovered via `~/.config/quickshell`), started
by Hyprland autostart. QuickShell **hot-reloads on file save** — do not
restart it to apply changes. If a reload ever wedges the scene (rare, after
structural changes), `touch shell.qml` to force another reload cycle.

## Layout

- `shell.qml` → `Bar.qml` — the panel window and module layout
- `Theme.qml` — singleton: palette, fonts, metrics, all style tokens
- `components/` — building blocks: `BarPill` (a module pill), `BarPopup`
  (popup bubble attached to a pill), `BarTooltip`, `Spinner`
- `modules/` — one file per bar module (workspaces, clock, volume, …)

## Rules to preserve

- **All styling flows through `Theme.qml`.** Modules declare an `accent`
  color (plus `neutral` for their inactive state) and `BarPill`/`Theme`
  decide how it renders. Never hardcode colors or metrics in modules.
- **Fonts live only in `Theme.qml`.** Text is Iosevka; icon glyphs are pinned
  per origin: Material Design Icons for supplementary-plane codepoints
  (U+F0000+), Symbols Nerd Font for BMP private-use ones.
- **Write icon characters as `\u{...}` escapes, never as literals** —
  private-use literals silently corrupt when files pass through tooling.
- **Pill widths must stay even integers** (see `BarPill.implicitWidth`), and
  every visible item in the bar's right row needs an integer width. Popup
  neck alignment depends on it: xdg popups are placed in whole pixels, so a
  fractional or odd-width pill shifts the popup by a pixel.
- **New popups reuse `BarPopup`** — it provides the emerging-from-the-pill
  treatment (pill morphs via `popupAttached`, neck continues its borders),
  outside-click dismissal via `HyprlandFocusGrab`, and size-morph animations.
  Pass the bar window as `anchorWindow` so clicking the pill toggles cleanly.
- **Do not add `MultiEffect` shadows to popup surfaces** — its second draw of
  the source fattens outlines; the `BarPopup` canvas draws its own shadow.
- **Motion uses the Material 3 expressive curves** already present in the
  code (springy `[0.42, 1.67, 0.21, 0.90]` for spatial moves, ~200ms
  decelerate for fades, quick accelerate for exits). Match them.
- Behaviors that must keep working: module actions (clicks, wheel scrolling),
  the calendar tooltip (scroll shifts months, right click toggles month/year,
  middle click resets), locale-aware date via `LC_TIME`, and the custom
  scripts in `~/.local/bin` (`check-updates`, `yubikey-touch-status`).

## Managing

- IPC endpoints (also handy for keybinds):
  `qs ipc call bluetooth toggle|connect <name>|disconnect <name>` and
  `qs ipc call updates refresh` (wire it to a pacman hook for instant
  update-count refreshes).
- Popups can be driven through IPC for headless testing; verify visuals with
  `grim -o DP-1 out.png` (hyprshot hangs on its clipboard step). Nothing can
  be captured while hyprlock is up.
