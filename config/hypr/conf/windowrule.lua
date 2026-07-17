-- Layer rules

-- QuickShell bar and its popups (bluetooth list, tooltips) are xdg-popups of
-- the same layer, so blur_popups is needed in addition to blur to reach them.
hl.layer_rule({
  name = "quickshell-blur",
  match = { namespace = "quickshell" },

  blur = true,
  blur_popups = true,
  -- Keep below the bar/popup surface alpha so blur still applies to the fill,
  -- while skipping the fully-transparent shadow margin around rounded corners.
  ignore_alpha = 0.2,
})

-- Tagging for future use

-- Browser
hl.window_rule({
  match = { initial_class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|Microsoft-edge)" },
  tag = "+chromium-based-browser",
})
hl.window_rule({
  match = { tag = "chromium-based-browser", initial_title = "^(Meet.+)$", float = true },
  tag = "+pip",
})
hl.window_rule({
  match = { initial_title = "^(meet.google.com is sharing a window.)" },
  tag = "+share",
})

-- Configs

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
  name = "suppress-maximize",
  match = { class = ".*" },

  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-drag",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

-- No-border when single window
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })

hl.window_rule({
  name = "no-border-single-tiled",
  match = { float = false, workspace = "w[tv1]" },

  border_size = 0,
  rounding = 0,
})

hl.window_rule({
  name = "no-border-single-fullscreen",
  match = { float = false, workspace = "f[1]" },

  border_size = 0,
  rounding = 0,
})

-- Picture-in-picture
hl.window_rule({
  name = "pip",
  match = { tag = "pip" },

  -- These don't work, Chrome does something strange when opening the PiP window :(
  float = true,
  pin = true,
  opaque = true,

  border_size = 0,
  no_dim = true,
  no_follow_mouse = true,
  no_shadow = true,
})

-- Share indicators
hl.window_rule({
  name = "share-indicator",
  match = { tag = "share" },

  move = { "(monitor_w-window_w)", "(monitor_h-window_h-10)" },

  border_size = 0,
  no_follow_mouse = true,
  no_shadow = true,
})

-- App-specific

-- Screensaver
hl.window_rule({
  name = "screensaver",
  match = { class = "Screensaver" },

  fullscreen = true,
})

-- Calculator
hl.window_rule({
  name = "calculator",
  match = { class = "org.gnome.Calculator" },

  float = true,
})

-- File dialog
hl.window_rule({
  name = "file-dialog",
  match = {
    class = "xdg-desktop-portal-gtk",
    title = "^(Open.*Files?|Open [Ff]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to (open|save).*|[Cc]hoose.*)",
  },

  float = true,
  center = true,
  size = { 1024, 768 },
})

-- Satty
hl.window_rule({
  name = "satty",
  match = { initial_class = "com.gabm.satty" },

  float = true,
  center = true,
  size = { 1024, 768 },
  pin = true,
})

-- Slack
hl.window_rule({
  name = "slack-screenshare",
  match = { class = "^([sS]lack)$" },

  no_screen_share = true,
})

hl.window_rule({
  name = "slack",
  match = { initial_class = "^([sS]lack)$" },

  workspace = "10",
  no_initial_focus = true,
})

-- Spotify
hl.window_rule({
  name = "spotify",
  match = { initial_class = "^([sS]potify)$" },

  workspace = "9",
  no_initial_focus = true,
})

-- Kingdom Battle
hl.window_rule({
  name = "kingdom-battle",
  match = { initial_class = "^(kingdom-battle)$" },

  workspace = "8",
  no_initial_focus = true,
})

-- 1Password
hl.window_rule({
  name = "1password",
  match = { initial_class = "1password" },

  size = { "(monitor_w*0.8)", "(monitor_h*0.9)" },

  float = true,
  center = true,
  pin = true,
})
