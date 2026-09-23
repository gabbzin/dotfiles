hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" }, -- ".*" = qualquer classe
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$", -- classe vazia
		title = "^$", -- título vazio
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true, -- não rouba o foco
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

-- GESTO de touchpad: 3 dedos na horizontal troca de workspace.
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.window_rule({
  name = "float-file-chooser",
  match = { class = "code", title = "Abrir a Pasta" },
  float = true,
  size = { 900, 500 },
})