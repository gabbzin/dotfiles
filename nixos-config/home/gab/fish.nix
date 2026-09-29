# Fish = seu (tide + mise). Espelho do flake antigo.
# TODO Etapa 3: trazer aliases docker/sshd, pnpm, android, functions work/scope-stop.
{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting ""

      ${pkgs.mise}/bin/mise activate fish | source
    '';

    # Atalhos de edição do sistema (flake versionado).
    shellAliases = {
      nixconf = "$EDITOR ~/dotfiles/nixos-config/flake.nix";
      nixapps = "$EDITOR ~/dotfiles/nixos-config/home/gab/packages.nix";
      nixsys = "$EDITOR ~/dotfiles/nixos-config/modules/system/core.nix";
      nixcheck = "nix --extra-experimental-features 'nix-command flakes' flake check --no-build ~/dotfiles/nixos-config";
      # Docker (resgatados do dotfile antigo)
      docker-start = "echo 'Iniciando o docker chefe'; sudo systemctl start docker";
      docker-stop = "echo 'Parando o docker'; sudo systemctl stop docker";
      docker-status = "systemctl status docker";
      docker-restart = "echo 'Reiniciando o docker...'; sudo systemctl restart docker";
      docker-ps-no-port = "docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}\t{{.Names}}'";
    };

    functions = {
      rebuild = {
        description = "Aplica o flake versionado (switch + reload + restart shell)";
        body = ''
          sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config#nixos
          and hyprctl reload
          and systemctl --user restart caelestia
        '';
      };

      _tide_item_newline = {
        description = "Shim do tide v6.2.0 (ver fish.nix)";
        body = ''
          set_color $prev_bg_color -b normal
          set -l v tide_"$_tide_side"_prompt_suffix
          echo $$v
          set -g add_prefix
        '';
      };
    };
  };
}
