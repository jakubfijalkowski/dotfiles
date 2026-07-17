local mainMod = "SUPER"

-- General
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(
  mainMod .. " + F",
  hl.dsp.window.fullscreen({ action = "toggle" }),
  { description = "Toggle fullscreen" }
)
hl.bind(
  mainMod .. " + U",
  hl.dsp.window.float({ action = "toggle" }),
  { description = "Toggle floating flag" }
)

hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle window grouping" })
hl.bind(
  mainMod .. " + ALT + G",
  hl.dsp.window.move({ out_of_group = true }),
  { description = "Move active window out of group" }
)

hl.bind(
  mainMod .. " + mouse:272",
  hl.dsp.window.drag(),
  { mouse = true, description = "Move window" }
)
hl.bind(
  mainMod .. " + mouse:273",
  hl.dsp.window.resize(),
  { mouse = true, description = "Resize window" }
)

-- Applications
hl.bind(
  mainMod .. " + SPACE",
  hl.dsp.exec_cmd("uwsm-app -- walker"),
  { description = "Launch apps" }
)
hl.bind(
  mainMod .. " + R",
  hl.dsp.exec_cmd("uwsm-app -- walker --provider runner"),
  { description = "Launch cmd" }
)
hl.bind(
  mainMod .. " + C",
  hl.dsp.exec_cmd("uwsm-app -- walker --provider clipboard"),
  { description = "Clipboard history" }
)

hl.bind(
  mainMod .. " + E",
  hl.dsp.exec_cmd("uwsm-app -- nautilus"),
  { description = "Launch Nautilus" }
)
hl.bind(
  mainMod .. " + Return",
  hl.dsp.exec_cmd("uwsm-app -- xdg-terminal-exec"),
  { description = "Launch Terminal" }
)

hl.bind(
  "PRINT",
  hl.dsp.exec_cmd("hyprshot -m output --raw | satty --filename -"),
  { description = "Screen screenshot" }
)
hl.bind(
  "SHIFT + PRINT",
  hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"),
  { description = "Region screenshot" }
)
hl.bind(
  "CTRL + SHIFT + PRINT",
  hl.dsp.exec_cmd("hyprshot -m window --raw | satty --filename -"),
  { description = "Window screenshot" }
)

-- Notifications (handled by the QuickShell notification server)
hl.bind(
  mainMod .. " + COMMA",
  hl.dsp.exec_cmd("qs ipc call notifs toggleDnd"),
  { description = "Toggle do-not-disturb" }
)
hl.bind(
  mainMod .. " + ALT + COMMA",
  hl.dsp.exec_cmd("qs ipc call notifs dismissLast"),
  { description = "Dismiss last notification" }
)
hl.bind(
  mainMod .. " + SHIFT + COMMA",
  hl.dsp.exec_cmd("qs ipc call notifs dismissAll"),
  { description = "Dismiss all notifications" }
)

-- Movements
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "Move focus left" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "Move focus down" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "Move focus up" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "Move focus right" })

hl.bind(
  mainMod .. " + SHIFT + H",
  hl.dsp.window.swap({ direction = "l" }),
  { description = "Swap window left" }
)
hl.bind(
  mainMod .. " + SHIFT + J",
  hl.dsp.window.swap({ direction = "d" }),
  { description = "Swap window down" }
)
hl.bind(
  mainMod .. " + SHIFT + K",
  hl.dsp.window.swap({ direction = "u" }),
  { description = "Swap window up" }
)
hl.bind(
  mainMod .. " + SHIFT + L",
  hl.dsp.window.swap({ direction = "r" }),
  { description = "Swap window right" }
)

-- Switch workspaces with mainMod + [0-9] (0 maps to workspace 10)
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = i % 10
  hl.bind(
    mainMod .. " + " .. key,
    hl.dsp.focus({ workspace = i }),
    { description = "Switch to workspace " .. i }
  )
  hl.bind(
    mainMod .. " + SHIFT + " .. key,
    hl.dsp.window.move({ workspace = i }),
    { description = "Move to workspace " .. i }
  )
end

hl.bind(mainMod .. " + TAB", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.group.prev(), { description = "Prev window in group" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true }
)
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  { locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
