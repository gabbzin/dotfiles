local home = os.getenv("HOME")

local wallpaper = home .. "/Pictures/wallpapers/Abstract - Nature.jpg"

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("/usr/libexec/hyprpolkitagent")
	hl.exec_cmd("swww-daemon --format xrgb")
	hl.exec_cmd("swww img " .. wallpaper)
	hl.exec_cmd("qs --daemonize")
	-- waybar e swaync migrados para quickshell (Fase 3-4) — removidos
	-- para reativar waybar temporariamente: hl.exec_cmd("waybar")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
