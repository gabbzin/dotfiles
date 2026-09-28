# Pacotes de usuário. Flakes
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    python3
    mise
    # Deps do Neovim (Treesitter compila parsers, Telescope busca)
    gcc
    ripgrep
    fd
    lazygit
    wakatime-cli
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
