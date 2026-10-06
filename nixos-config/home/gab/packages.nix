# Pacotes de usuário. Flakes
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
    # JARVIS: voz + tema instrumental
    espeak-ng
    mpv
    libnotify
    (python3.withPackages (ps: with ps; [ speechrecognition pyaudio ]))
    gcc
    ripgrep
    fd
    lazygit
    wakatime-cli
    code-cursor
  ];

  # "Rebuild NixOS" para o commands do launcher
  xdg.desktopEntries.nixos-rebuild = {
    name = "Rebuild NixOS";
    comment = "Aplica o flake versionado (switch + reload)";
    exec = "kitty --hold fish -c rebuild";
    icon = "system-software-update";
    categories = [ "System" ];
  };
}
