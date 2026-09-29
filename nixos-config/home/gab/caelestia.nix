# Caelestia = prioridade para Hyprland (base).
# Etapa 2 vai adicionar hypr-vars.lua (kitty, SUPER+D) + hypr-user.lua (atalhos resgatados).
{ caelestia-shell, pkgs, ... }:

{
  imports = [ caelestia-shell.homeManagerModules.default ];

  home.stateVersion = "26.05";

  programs.caelestia = {
    enable = true;
    cli.enable = true;

    # Patch versionado: % da bateria no lugar do ícone (sem chave upstream).
    package = caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        cp ${../../files/caelestia/BatteryStatus.qml} modules/bar/components/status/BatteryStatus.qml
      '';
    });

    # Barra: mostra só o nome do programa (último segmento após " - "),
    # em vez do título completo da janela.
    settings = {
      bar.activeWindow.compact = true;
      bar.clock.showDate = true;
      bar.clock.showSeconds = false;
      sidebar.enabled = true;
      notifs.expire = true;
      # Seus wallpapers viram a galeria do launcher (SUPER+D > ">wallpaper ").
      paths.wallpaperDir = "/home/gab/images/wallpapers";
      # Mais miniaturas visíveis de uma vez (ímpar; tela limita o máximo real).
      launcher.maxWallpapers = 9;
      # Sem moldura na tela: só a barra lateral.
      border.thickness = 0;
      border.rounding = 0;
      # TRIAGE crash do dashboard: aba de mídia religada a pedido; se o
      # SIGKILL voltar ao abrir o painel, o gatilho é o widget de mídia.
      dashboard.showMedia = true;
      # Dashboard religado (precisa do % da bateria); crash em investigação.
      dashboard.enabled = true;
    };
  };
}
