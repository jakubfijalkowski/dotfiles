local colors = require("conf/colors")

hl.config({
  general = {
    gaps_in = 1,
    gaps_out = 2,

    border_size = 2,

    col = {
      active_border = colors.activeBorderColor,
      inactive_border = colors.inactiveBorderColor,
    },

    resize_on_border = true,
    allow_tearing = false,

    layout = "dwindle",
  },

  binds = {
    workspace_back_and_forth = true,
  },

  group = {
    col = {
      border_active = colors.activeBorderColor,
      border_inactive = colors.inactiveBorderColor,
    },

    groupbar = {
      font_size = 12,
      font_family = "monospace",
      font_weight_active = "heavy",
      font_weight_inactive = "normal",

      indicator_height = 0,
      indicator_gap = 2,
      height = 22,
      gaps_in = 2,
      gaps_out = 0,

      text_color = colors.tint1,
      text_color_inactive = "rgba(" .. colors.textAlpha .. "90)",
      col = {
        active = colors.surface0,
        inactive = colors.base,
      },

      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "slave",
  },

  misc = {
    disable_hyprland_logo = true,
    force_default_wallpaper = 0,
  },

  decoration = {
    rounding = 1,
    rounding_power = 2,

    dim_inactive = true,
    dim_strength = 0.3,

    inactive_opacity = 0.8,

    shadow = {
      enabled = true,
    },

    blur = {
      enabled = true,
    },
  },

  animations = {
    enabled = true,
  },
})

-- Default curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#curves
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({
  leaf = "windowsIn",
  enabled = true,
  speed = 4.1,
  spring = "easy",
  style = "popin 87%",
})
hl.animation({
  leaf = "windowsOut",
  enabled = true,
  speed = 1.49,
  bezier = "linear",
  style = "popin 87%",
})
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({
  leaf = "layersIn",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "fade",
})
hl.animation({
  leaf = "layersOut",
  enabled = true,
  speed = 1.5,
  bezier = "linear",
  style = "fade",
})
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 1.94,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({
  leaf = "workspacesIn",
  enabled = true,
  speed = 1.21,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({
  leaf = "workspacesOut",
  enabled = true,
  speed = 1.94,
  bezier = "almostLinear",
  style = "fade",
})
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
