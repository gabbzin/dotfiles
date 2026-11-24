-- Monitor principal x auxiliar. Fonte da verdade: o mesmo estado do SUPER+U (ui-primary),
-- ou seja, o monitor cujo ~/.config/caelestia/monitors/<nome>/shell.json NÃO tem
-- "enabled": false. Sem estado (ou "todos"), o notebook é o principal.
local M = {}

M.internal = "eDP-1"
M.external = "HDMI-A-1"

local function is_aux(name)
    local f = io.open(os.getenv("HOME") .. "/.config/caelestia/monitors/" .. name .. "/shell.json", "r")
    if not f then return false end
    local content = f:read("*a")
    f:close()
    return content:find('"enabled"%s*:%s*false') ~= nil
end

-- Relê o estado a cada chamada (o SUPER+U muda isso sem recarregar o Hyprland).
function M.get()
    if is_aux(M.internal) and not is_aux(M.external) then
        return M.external, M.internal
    end
    return M.internal, M.external
end

-- Id do workspace ativo no monitor principal, independente de onde está o foco.
-- IMPORTANTE: usa só a API nativa (hl.get_monitors). NÃO chamar `hyprctl` daqui: o Lua roda
-- dentro do compositor, e o hyprctl fala com o próprio Hyprland por IPC, que fica esperando
-- a mesma thread que está esperando o hyprctl (deadlock até o timeout, tela congelada).
function M.active_workspace_id()
    local primary = M.get()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name == primary then
            local ws = m.active_workspace
            return ws and ws.id or nil
        end
    end
    return nil
end

return M
