local mod = "SUPER"

local terminal = "kitty"
local menu = "rofi -show drun"
local screenshot = 'grim -g "$(slurp)" - | wl-copy'
local screenshot_full = "grim - | wl-copy"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal)) -- Executa Terminal
hl.bind(mod .. " + D", hl.dsp.exec_cmd(menu)) -- Executa Rofi
hl.bind(mod .. " + Q", hl.dsp.window.close()) -- Fecha Window
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" })) -- flutuar
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo()) -- pseudo-tile (janela flutuando com tile)
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit")) -- inverter divisão do tile
hl.bind(mod .. " + R", hl.dsp.exec_cmd("hyprctl reload")) -- recarregar config
hl.bind(mod .. " + M", hl.dsp.exit()) -- sair da sessão

-- Navegação de foco entre janelas (dwindle).
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Mover a janela focada na direção.
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Trocar de workspace com a roda do mouse segurando o mod.
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- 272 = botão esquerdo, 273 = botão direito (códigos X11).
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(screenshot_full))

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
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
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
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(
  "XF86AudioPause",
  hl.dsp.exec_cmd("playerctl play-pause"),
  { locked = true }
)
hl.bind(
  "XF86AudioPlay",
  hl.dsp.exec_cmd("playerctl play-pause"),
  { locked = true }
)
hl.bind(
  "XF86AudioPrev",
  hl.dsp.exec_cmd("playerctl previous"),
  { locked = true }
)

hl.define_submap("resize", function()
  hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0 }))
  hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0 }))
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20 }))
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20 }))
  hl.bind("Escape", hl.dsp.submap("reset"))
end)
-- SUPER+L ativa o submapa "resize".
hl.bind(mod .. " + L", hl.dsp.submap("resize"))
