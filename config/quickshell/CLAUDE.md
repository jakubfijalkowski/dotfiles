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

- `shell.qml` → `Bar.qml` (the panel window + module layout) and
  `NotificationOverlay.qml` (the transient toast stack)
- `Theme.qml` — singleton: palette, fonts, metrics, all style tokens
- `Notifs.qml` — singleton: the freedesktop notification server, do-not-disturb
  state, and the live-toast list
- `Icons.qml` — singleton: shared app-icon resolution (memoizes hits; misses
  are retried since desktop entries scan in asynchronously)
- `Time.qml` — singleton: the one shared `SystemClock` (clock pills, calendar)
- `Screens.qml` — singleton: which monitor the shell lives on; every window
  resolves its `screen` through `Screens.primary`
- `components/` — building blocks: `BarPill` (a module pill), `BarDrawer` /
  `EdgeDrawer` (shade drawers that flow out of the bar; shared seam painting
  lives in `drawerShapes.js`), `BarTooltip`, `NotificationToast`,
  `ActionButton` (tinted footer button), `StyledSlider` (the shared slider
  look), `ExpandArea`, `Spinner`
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
- **New popups are drawers** — reuse `BarDrawer` (drops below its pill) or
  `EdgeDrawer` (top-right corner). They flow out of the bar rather than
  floating below it: their top edge meets the bar and they open like a shade.
  Each takes a `required` `accent` (the launching module's colour), painted as
  a neon seam trim (crisp core + soft glow) along that top edge — this both
  masks the faint blur-mismatch line where two translucent surfaces meet and
  makes the drawer read as the pill's colour flowing out. Every instance must
  pass `accent`. A click anywhere outside the drawer — including on the bar
  or the launching pill — dismisses it via `HyprlandFocusGrab`; the grab
  holds only the drawer itself. Shape + seam tokens live in `Theme`
  (`drawer*`), the seam painting in `components/drawerShapes.js`.
- **Notifications are transient toasts, not a panel.** `Notifs` runs the
  freedesktop server (no history, no persistence) and feeds a *local*
  `ListModel` to `NotificationOverlay`; drive the toast Repeater from that,
  never straight from the server's `trackedNotifications` — removing a non-tail
  entry there rebuilds every delegate and flashes the just-closed toast. The
  overlay is a **fixed-size** masked layer surface that never resizes as toasts
  come and go: they reflow *within* it (resizing the surface per toast visibly
  jitters the stack). A toast slides in from the right, auto-dismisses after
  its lifetime (`Theme`-configured default, or the sender's; critical stays),
  and on close collapses its own height so the rest slide up. Colour follows
  urgency via `Theme.notifAccent`. Left-click on the card invokes the sender's
  *default* action; any other actions render as accent chips below the body.
- **Popups have no drop shadow, by design** — depth comes from the translucent
  fill plus the border under the Hyprland blur. Don't add one: `MultiEffect`
  / `DropShadow` resample the whole surface and fatten the 1px border. The
  transparent margins around the drawer body are only breathing room for the
  seam glow and the blur, not shadow space.
- **Motion uses the Material 3 expressive curves** already present in the
  code (springy `[0.42, 1.67, 0.21, 0.90]` for spatial moves, ~200ms
  decelerate for fades, quick accelerate for exits). Match them.
- Behaviors that must keep working: module actions (clicks, wheel scrolling),
  the calendar drawer (wheel over the pill or the calendar shifts months,
  middle click resets to the current month), locale-aware date via `LC_TIME`,
  and the custom scripts in `~/.local/bin` (`check-updates`,
  `yubikey-touch-status`).

## Managing

- IPC endpoints (also handy for keybinds and for testing, below): every popup
  exposes a `toggle` on its module's target —
  `qs ipc call bluetooth toggle`, `qs ipc call updates toggle`,
  `qs ipc call audio toggle`, `qs ipc call mpris toggle`,
  `qs ipc call calendar toggle` — plus
  `qs ipc call bluetooth connect <name>|disconnect <name>` and
  `qs ipc call updates refresh` (wire `refresh` to a pacman hook for instant
  update-count refreshes). Notifications expose
  `qs ipc call notifs dismissAll|dismissLast|toggleDnd` and
  `qs ipc call notifs dnd <on|off>` — `dismissAll` / `toggleDnd` are bound to
  keys in Hyprland (`conf/keybindings.lua`).
- **Testing interactive changes is a do → screenshot → undo cycle** — never
  just eyeball the code. Save the file (it hot-reloads; give it a second),
  drive the state you want to inspect, capture it, then reverse the action so
  the bar is left exactly as the user had it. For popups this is:
  1. **Do** — open it via IPC, e.g. `qs ipc call audio toggle`. Prefer IPC
     over faking a click; it's the same code path and works headless.
  2. **Wait** — the open spring and size-morph run ~350ms, so `sleep 0.5`
     before capturing or you'll photograph a mid-animation frame.
  3. **Screenshot** — `grim -o DP-1 out.png`, then Read the PNG. Capture the
     whole DP-1 output, not a region: popups are xdg-popups that extend past
     their pill. hyprshot hangs on its clipboard step, and nothing can be
     captured while hyprlock is up.
  4. **Undo** — `qs ipc call audio toggle` again to close it. Leave no popup
     open behind you. (Tooltips and other hover-only states have no IPC
     toggle — reverse those by whatever means opened them.)
- Blur is configured in Hyprland, not here. The bar is a layer surface with
  namespace `quickshell`; its popups/tooltips are xdg-popups of that same
  layer (not their own surfaces), so `blur` alone won't reach them:
  `layerrule = blur, quickshell` + `layerrule = blurpopups, quickshell`, plus
  an `ignorealpha` below the surface alpha to spare the transparent margins.
  Re-derive the live namespace with `hyprctl layers`.
