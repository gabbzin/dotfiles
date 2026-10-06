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
      -- SUPER+D é do launcher; tira o workspace de comunicação do caminho.
      kbCommunicationWs = "SUPER + SHIFT + D",

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

    -- SUPER+ALT+setas troca de workspace (-1/+1, resgatado do dotfile antigo).
    hl.bind("SUPER + ALT + left", hl.dsp.focus({ workspace = "-1" }))
    hl.bind("SUPER + ALT + right", hl.dsp.focus({ workspace = "+1" }))

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
