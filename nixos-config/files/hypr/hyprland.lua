local home   = os.getenv("HOME")
local hypr   = home .. "/.config/hypr"
package.path = package.path .. ";" .. home .. "/.config/caelestia/?.lua"

-- Create a file if it doesn't exist, optionally with initial content
local function maybe_create(file, content)
    local f = io.open(file)

    if f then
        f:close()
        return
    end

    f = io.open(file, "w")
    if f then
        if content then f:write(content) end
        f:close()
    end
end

-- Copy src to dst, but only if dst doesn't already exist
local function maybe_copy(src, dst)
    local out = io.open(dst)
    if out then
        out:close()
        return
    end

    local input = io.open(src, "r")
    if not input then return end

    out = io.open(dst, "w")
    if out then
        out:write(input:read("*a"))
        out:close()
    end
    input:close()
end

-- Maybe set current colours to defaults
maybe_copy(hypr .. "/scheme/default.lua", hypr .. "/scheme/current.lua")

-- UI variant (default | glass | ...), escolhida em runtime pelo script `ui-variant`,
-- que grava o nome em ~/.local/state/caelestia/ui-variant. Qualquer falha cai em "default".
local function load_variant()
    local name = "default"
    local f = io.open(home .. "/.local/state/caelestia/ui-variant", "r")
    if f then
        local content = f:read("*l")
        f:close()
        if content and content:match("^[%w_-]+$") then name = content end
    end

    local ok, variant = pcall(require, "variants." .. name)
    if not ok or type(variant) ~= "table" then
        return require("variants.default")
    end
    return variant
end
local variant = load_variant()

-- Variant vars primeiro; o hypr-vars.lua do usuário vem depois e tem a palavra final.
local vars = require("variables")
for k, v in pairs(variant.vars or {}) do
    vars[k] = v
end

-- User variables
maybe_create(home .. "/.config/caelestia/hypr-vars.lua", "return {}\n")
local overrides = require("hypr-vars")
if type(overrides) == "table" then
    for k, v in pairs(overrides) do
        vars[k] = v
    end
end

-- Default monitor conf
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Configs
require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("hyprland.group")
require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")

-- Variant extras (layer rules, animações, blur avançado)
if type(variant.apply) == "function" then
    local ok, err = pcall(variant.apply, vars)
    if not ok then
        hl.exec_cmd("notify-send -u critical 'UI variant' 'Erro no apply(): " .. tostring(err):gsub("'", "") .. "'")
    end
end

-- User configs
maybe_create(home .. "/.config/caelestia/hypr-user.lua")
require("hypr-user")
