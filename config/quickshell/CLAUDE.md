# QuickShell bar

A QuickShell (Wayland/Hyprland) status bar for the DP-1 monitor, styled as a
Catppuccin Mocha "Neon" outline look: dark translucent bar, pills that carry
their module's color in border and text, and a matching translucent popup
that drops open just below its pill. The bar and popups are deliberately
translucent so a Hyprland blur layer shows through (see Managing).

Runs with `qs` (config auto-discovered via `~/.config/quickshell`), started
by Hyprland autostart. QuickShell **hot-reloads on file save** — do not
restart it to apply changes. If a reload ever wedges the scene (rare, after
structural changes), `touch shell.qml` to force another reload cycle.

**Never launch a second `qs` yourself.** A bad config does not kill
Quickshell — it keeps the last good scene and logs the error (`qs log`), then
picks up the fix on the next save. The autostart process runs as
`/usr/bin/quickshell`, so `pgrep -a qs` won't show it — check with
`pgrep -a quickshell`.

## Layout

- `shell.qml` → `Bar.qml` — the panel window and module layout
- `Theme.qml` — singleton: palette, fonts, metrics, all style tokens
- `components/` — building blocks: `BarPill` (a module pill), `BarPopup`
  (rounded-rectangle popup that opens below a pill), `BarTooltip`, `Spinner`
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
  every visible item in the bar's right row needs an integer width. This keeps
  the popup centered on its pill: xdg popups are placed in whole pixels, so a
  fractional or odd-width pill shifts the popup by a pixel.
- **New popups reuse `BarPopup`** — a plain rounded-rectangle `Rectangle`
  (native `radius` + `border`, colored by `ringColor`) that opens `gap` px
  below the pill. It provides outside-click dismissal via `HyprlandFocusGrab`,
  a springy scale-from-top open and size-morph animations. Pass the bar window
  as `anchorWindow` so clicking the pill toggles cleanly (the bar joins the
  focus grab, so a pill click closes instead of dismiss-then-reopen).
- **Popups have no drop shadow, by design** — depth comes from the translucent
  fill plus the border under the Hyprland blur. Don't add one: `MultiEffect`
  / `DropShadow` resample the whole surface and fatten the 1px border. The
  transparent `margin` around the bubble is only breathing room so the open
  spring's overshoot past scale 1.0 isn't clipped by the window bounds.
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
- Blur is configured in Hyprland, not here. The bar is a layer surface with
  namespace `quickshell`; its popups/tooltips are xdg-popups of that same
  layer (not their own surfaces), so `blur` alone won't reach them:
  `layerrule = blur, quickshell` + `layerrule = blurpopups, quickshell`, plus
  an `ignorealpha` below the surface alpha to spare the transparent margins.
  Re-derive the live namespace with `hyprctl layers`.
