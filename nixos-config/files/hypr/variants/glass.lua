-- Variante "glass": vidro translúcido estilo Liquid Glass (sem refração real).
-- Blur forte + vibrancy, cantos squircle, janelas translúcidas, borda com brilho.
return {
    vars = {
        -- Blur
        blurSize            = 12,
        blurPasses          = 3,
        blurXray            = false,

        -- Janelas
        windowOpacity       = 0.82,
        windowRounding      = 22,
        windowRoundingPower = 3, -- cantos "squircle"
        windowBorderSize    = 1,

        -- Borda: brilho claro diagonal na janela ativa, quase invisível nas outras
        -- (gradiente em Lua é tabela; a string "cor cor 45deg" do hyprlang é inválida aqui)
        activeWindowBorderColour   = { colors = { "rgba(ffffff66)", "rgba(ffffff14)" }, angle = 45 },
        inactiveWindowBorderColour = "rgba(ffffff1c)",

        -- Sombra grande e suave, neutra (sem tingir com a cor do tema)
        shadowRange       = 32,
        shadowRenderPower = 3,
        shadowColour      = "rgba(00000050)",
    },

    apply = function(vars)
        -- Parâmetros de blur que o decoration.lua base não expõe via variables
        hl.config({
            decoration = {
                blur = {
                    vibrancy          = 0.25,
                    vibrancy_darkness = 0.2,
                    noise             = 0.015,
                    contrast          = 1.0,
                    brightness        = 1.0,
                },
            },
        })

        -- Painéis do shell em vidro. O Caelestia também liga isso em runtime quando
        -- a transparência está ativa, mas o `hyprctl reload` apaga essa regra; manter
        -- estática aqui evita o painel ficar sem blur depois de trocar de variante.
        hl.layer_rule({ match = { namespace = "caelestia-drawers" }, blur = true, ignore_alpha = 0.3 })
        hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.3 })

        -- Animações mais fluidas, com leve overshoot
        hl.curve("glassSpring", { type = "bezier", points = { { 0.34, 1.25 }, { 0.64, 1 } } })
        hl.curve("glassSmooth", { type = "bezier", points = { { 0.25, 0.8 }, { 0.25, 1 } } })
        hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "glassSpring", style = "popin 88%" })
        hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "glassSmooth", style = "popin 92%" })
        hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "glassSpring" })
        hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "glassSmooth" })
        hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "glassSmooth" })
    end,
}
