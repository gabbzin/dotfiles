# Hyprland = base Caelestia (files/hypr, cópia versionada do dots) + overrides seus.
# - hypr-vars.lua: fundido em variables.lua pelo hyprland.lua do Caelestia.
# - hypr-user.lua: executado por último (require no fim do hyprland.lua).
# Sincronizar com upstream: diff -r files/hypr ~/GitHub/caelestia/hypr
{ ... }:

{
  xdg.configFile."hypr" = {
    source = ../../files/hypr;
    recursive = true;
  };

  # Apps reais desta máquina + seus atalhos (launcher SÓ SUPER+D).
  xdg.configFile."caelestia/hypr-vars.lua".text = ''
    return {
      terminal = "kitty",
      browser = "brave",
      editor = "code",
      fileExplorer = "dolphin",
      audioSettings = "pwvucontrol",

      cursorTheme = "Bibata-Modern-Ice",
      cursorSize = 24,

      kbLauncher = "SUPER + D",
      kbTerminal = { "SUPER + Return", "SUPER + T" },
      kbCloseWindow = "SUPER + Q",
      -- SUPER+D é do launcher (não mexe); modo de mensagens vai para SUPER+G.
      kbCommunicationWs = "SUPER + G",

      -- SUPER+U passa a alternar o monitor principal (ui-primary); "tirar do grupo" vai para SUPER+SHIFT+U.
      kbUngroup = "SUPER + SHIFT + U",

      windowGapsOut = 4,
      singleWindowGapsOut = 4,

      -- Swipe de 3 dedos troca workspace (Caelestia usa 4; gesto de 3 dedos p/ cima/baixo continua indo pro special).
      workspaceSwipeFingers = 3,
    }
  '';

  # Resgates do dotfile antigo (dotfiles/hyprland, em análise).
  xdg.configFile."caelestia/hypr-user.lua".text = ''
    -- ALT+F4 também fecha a janela (hábito Windows).
    hl.bind("ALT + F4", hl.dsp.window.close())

    -- JARVIS: sem trava de workspace (regras removidas de propósito).
    -- O jarvis instancia direto no ws via exec_cmd com workspace.
    -- Spotify continua no special:music (padrão do Caelestia em rules.lua, SUPER+M puxa).

    -- JARVIS: SUPER+J abre o setup direto, SUPER+SHIFT+J é push-to-talk.
    -- Caminho absoluto porque o Hyprland não herda o PATH do fish.
    hl.bind("SUPER + J", hl.dsp.exec_cmd("/home/gab/.local/bin/jarvis"))
    hl.bind("SUPER + SHIFT + J", hl.dsp.exec_cmd("/home/gab/.local/bin/jarvis-push"))
    -- Tecla Copilot do ThinkPad (wev: SUPER+SHIFT+key201 XF86Assistant).
    -- Sozinha = setup direto; com ALT segurado = push-to-talk.
    hl.bind("SUPER + SHIFT + XF86Assistant", hl.dsp.exec_cmd("/home/gab/.local/bin/jarvis"))
    hl.bind("SUPER + SHIFT + ALT + XF86Assistant", hl.dsp.exec_cmd("/home/gab/.local/bin/jarvis-push"))

    -- SUPER+Return abre o kitty limpo (kbTerminal); SUPER+ALT+Return
    -- pergunta o nome antes (kitty-title). Dentro do kitty, o rename
    -- continua no Ctrl+Shift+Alt+T nativo.
    hl.bind("SUPER + ALT + Return", hl.dsp.exec_cmd("kitty-title"))

    -- SUPER+SHIFT+F: "preenche a tela mantendo a barra". Se a janela estiver flutuante,
    -- deixa de flutuar e maximiza; se não, alterna maximizado (SUPER+F segue sendo fullscreen).
    hl.bind("SUPER + SHIFT + F", function()
      local a = hl.get_active_window()
      if a and a.floating then
        hl.dispatch(hl.dsp.window.float())
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
      else
        hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
      end
    end)

    -- SUPER+ALT+setas troca de workspace (-1/+1, resgatado do dotfile antigo).
    -- (wsstep parte do monitor principal, então funciona mesmo com o foco no auxiliar.)
    local fn = require("utils.functions")
    hl.bind("SUPER + ALT + left", fn.wsstep("focus", -1))
    hl.bind("SUPER + ALT + right", fn.wsstep("focus", 1))

    -- Tampa do notebook: switch:on = tampa fechada, switch:off = aberta (testado em runtime com log).
    -- Fechar: eDP-1 sai do ar e o Hyprland re-aloca os workspaces dele pro monitor externo.
    -- Abrir: eDP-1 volta no modo preferred (os workspaces ficam onde estão).
    -- Junto com isso, a barra do shell acompanha: vai para o externo ao fechar e volta ao abrir.
    hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(
      "hyprctl keyword monitor eDP-1,disable; /etc/profiles/per-user/gab/bin/ui-primary lid-close"
    ))
    hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(
      "hyprctl keyword monitor eDP-1,preferred,auto,1; /etc/profiles/per-user/gab/bin/ui-primary lid-open"
    ))

    -- SUPER+SHIFT+I: liga/desliga o "manter acordado" (caffeine): tela sem bloquear/apagar
    -- (o ícone de café na barra mostra o estado). Caminho absoluto: o Hyprland não herda o PATH do fish.
    hl.bind("SUPER + SHIFT + I", hl.dsp.exec_cmd("/etc/profiles/per-user/gab/bin/keep-awake toggle"))

    -- SUPER+U: alterna o monitor principal (o outro vira auxiliar, só com apps).
    hl.bind("SUPER + U", hl.dsp.exec_cmd("/etc/profiles/per-user/gab/bin/ui-primary toggle"))

    -- Foco/workspace em outro monitor não pode teleportar o mouse (os atalhos de workspace
    -- agem no monitor principal mesmo com o mouse no auxiliar).
    hl.config({
      cursor = { no_warps = true },
    })

    -- Teclado ABNT2 (o input.lua do Caelestia fixa "us").
    hl.config({
      input = {
        kb_layout = "br",
        kb_variant = "abnt2",
      },
    })

    -- Scroll natural no touchpad (padrão do Caelestia; explícito aqui pra travar o comportamento).
    hl.config({
      input = {
        touchpad = { natural_scroll = true },
      },
    })

    -- Agente de pareamento bluetooth (registra agent no BlueZ; sem ele Pairable=no).
    -- O módulo Bluetooth do Caelestia usa Quickshell.Bluetooth direto, o applet é só o agent + tray.
    hl.exec_cmd("blueman-applet")
  '';
}
