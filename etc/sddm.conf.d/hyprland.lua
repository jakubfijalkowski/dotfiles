-- Hyprland configuration for the SDDM greeter (Lua).
-- Copied to /opt/hyprsddm/hyprland.lua and started by CompositorCommand in
-- wayland.conf.

local cursorTheme = "Bibata-Modern-Ice"
local cursorSize = "24"

hl.env("HYPRCURSOR_THEME", cursorTheme)
hl.env("HYPRCURSOR_SIZE", cursorSize)

hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
end)

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_watchdog_warning = true,
    force_default_wallpaper = 0,
    initial_workspace_tracking = 1,
  },

  input = {
    numlock_by_default = true,
    kb_layout = "pl",
  },

  cursor = {
    no_warps = true,
    no_hardware_cursors = true,
  },
})

hl.window_rule({
  name = "sddm",
  match = { class = "^(sddm-greeter)$" },

  workspace = "emptym",
  fullscreen = true,
  stay_focused = true,
  no_anim = true,
  no_dim = true,
  no_shadow = true,
  decorate = false,
  border_size = 0,
  rounding = 0,
})
