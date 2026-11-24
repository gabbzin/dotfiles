# Pacotes de usuário. Flakes
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
    lua-language-server
    lua5_4 # `lua`/`luac` para checar a sintaxe da config do Hyprland (luac -p)
    espeak-ng
    mpv
    libnotify
    (python3.withPackages (ps: with ps; [ speechrecognition pyaudio ]))
    gcc
    ripgrep
    fd
    rsync
    lazygit
    wakatime-cli
    code-cursor
    prisma-engines
    biome
    ventoy
    unzip
    mission-center
    kdePackages.dolphin
    vscode
    zed-editor
    android-studio
    android-tools
    spotify
    brave
    mixing-station
    reaper
    fastfetch
    btop
    zip
    trash-cli
    gh
    heroic
    gpu-screen-recorder
    glib
    dconf
    hyprlauncher
    hyprpolkitagent
    hyprpicker
    fuzzel
    papirus-icon-theme
    (pkgs.writeShellScriptBin "kitty-title" ''
      t=$(fuzzel --dmenu --prompt "nome: " < /dev/null) || exit 0
      t=$(printf '%s' "$t" | tr -cd '[:alnum:] _-')
      if [ -z "$t" ]; then exec kitty; fi
      exec kitty --title "$t" fish -C "function fish_title; echo $t; end"
    '')
  ];

  home.sessionVariables = {
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
  };

  xdg.desktopEntries.nixos-rebuild = {
    name = "Rebuild NixOS";
    comment = "Aplica o flake versionado (switch + reload)";
    exec = "kitty --hold fish -c rebuild";
    icon = "system-software-update";
    categories = [ "System" ];
  };
}
