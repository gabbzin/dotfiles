local monitors = hl.get_monitors()

if #monitors == 0 then
	hl.monitor({
		output = "", -- aplicar em qualquer monitor
		mode = "preferred", -- resolução/refresh nativos do monitor
		position = "auto",
		scale = "1.0",
	})
	return
end

for _, monitor in ipairs(monitors) do
	hl.monitor({
		output = monitor.name,
		mode = "preferred",
		position = "auto",
		scale = "1.0",
	})
end
