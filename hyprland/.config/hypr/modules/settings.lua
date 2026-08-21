local colors = require("modules.colors")

local function rgba(hex, alpha)
  return "rgba(" .. hex:sub(2) .. (alpha or "ee") .. ")"
end

hl.config({
  general = {
    gaps_in = 5, -- espaço entre janelas vizinhas (px)
    gaps_out = 0, -- espaço entre janelas e a borda da tela (px)
    border_size = 2, -- grossura da borda da janela (px)
    col = {
      active_border = {
        colors = { rgba(colors.blue), rgba(colors.mauve) },
        angle = 45,
      },
      inactive_border = rgba(colors.surface1, "aa"),
    },
    layout = "dwindle",
    resize_on_border = false,
  },
  decoration = {
    rounding = 10,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = rgba(colors.crust, "ee"),
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  dwindle = {
    preserve_split = true,
  },
  input = {
    kb_layout = "br",
    kb_variant = "abnt2",
    repeat_rate = 25,
    repeat_delay = 300,
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
    },
  },
  misc = {
    force_default_wallpaper = 0, -- desliga o wallpaper padrão (usamos swww)
    disable_hyprland_logo = true,
  },
})

hl.curve(
  "easeOutQuint",
  { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } }
)
hl.curve(
  "easeInOutCubic",
  { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } }
)
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve(
  "almostLinear",
  { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } }
)
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
-- Spring usa física (massa/molé/damping) em vez de bezier.
hl.curve(
  "easy",
  { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 }
)

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({
  leaf = "border",
  enabled = true,
  speed = 5.39,
  bezier = "easeOutQuint",
})
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
hl.animation({
  leaf = "fadeIn",
  enabled = true,
  speed = 1.73,
  bezier = "almostLinear",
})
hl.animation({
  leaf = "fadeOut",
  enabled = true,
  speed = 1.46,
  bezier = "almostLinear",
})
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({
  leaf = "layers",
  enabled = true,
  speed = 3.81,
  bezier = "easeOutQuint",
})
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
hl.animation({
  leaf = "fadeLayersIn",
  enabled = true,
  speed = 1.79,
  bezier = "almostLinear",
})
hl.animation({
  leaf = "fadeLayersOut",
  enabled = true,
  speed = 1.39,
  bezier = "almostLinear",
})
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
hl.animation({
  leaf = "zoomFactor",
  enabled = true,
  speed = 7,
  bezier = "quick",
})

-- hl.env() define VARIÁVEIS DE AMBIENTE que os programas herdam.
-- É o equivalente moderno do antigo env = X, Y do hyprland.conf.
hl.env("XCURSOR_SIZE", "24") -- cursor (apps GTK)
hl.env("HYPRCURSOR_SIZE", "24") -- cursor (hyprland)
-- Vai até as chaves do gnome-keyring guardadas em $XDG_RUNTIME_DIR/gcr/ssh.
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/gcr/ssh")
