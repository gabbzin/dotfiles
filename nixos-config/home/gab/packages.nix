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
    # Prisma: engines Rust pro `generate` (o npm baixa binários que quebram no NixOS).
    # Usa o CLI do projeto (npx prisma) + engines daqui. Projetos em 7.x, engines 7.10.
    prisma-engines
    # Biome tem pacote nativo (sem BO de engines): CLI + VSCode usam o mesmo.
    biome
  ];

  home.sessionVariables = {
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
  };

  # "Rebuild NixOS" para o commands do launcher
  xdg.desktopEntries.nixos-rebuild = {
    name = "Rebuild NixOS";
    comment = "Aplica o flake versionado (switch + reload)";
    exec = "kitty --hold fish -c rebuild";
    icon = "system-software-update";
    categories = [ "System" ];
  };
}
