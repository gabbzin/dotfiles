hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
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

hl.window_rule({
  name = "float-blueman-manager",
  match = { class = "^(blueman-manager)$" },
  float = true,
})

hl.window_rule({
  name = "float-pavucontrol",
  match = { class = "^(pavucontrol)$" },
  float = true,
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
