local monitors = hl.get_monitors()

if #monitors == 0 then
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
  })
  return
end

for _, monitor in ipairs(monitors) do
  hl.monitor({
    output = monitor.name,
    mode = "preferred",
    position = "auto",
    scale = "auto",
  })
end
