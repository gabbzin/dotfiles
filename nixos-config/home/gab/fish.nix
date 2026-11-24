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
      complete -c cli -f -n __fish_use_subcommand -a "claude opencode google copilot"
      fish_add_path "$HOME/.local/bin"

      ${pkgs.mise}/bin/mise activate fish | source

      # WakaTime terminal, modo econômico: 1 heartbeat no máx a cada 120s,
      # só após comando, em background, silencioso. Projeto = git root ou pasta.
      set -g _wakatime_last_sent 0
      function __wakatime_hook --on-event fish_postexec -d "heartbeat leve WakaTime"
        command -q wakatime-cli; or return
        set -l now (date +%s)
        if test (math "$now - $_wakatime_last_sent") -lt 120
          return
        end
        set -g _wakatime_last_sent $now
        set -l proj (git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null); or set proj (basename "$PWD")
        test -z "$proj"; and set proj "Terminal"
        set -l cmd (string split -m1 " " -- $history[1])[1]
        test -z "$cmd"; and set cmd "fish"
        wakatime-cli --write --plugin "fish-wakatime/0.1" --entity-type app --project "$proj" --entity "$cmd" >/dev/null 2>&1 &
      end
    '';

    # Atalhos de edição do sistema (flake versionado).
    shellAliases = {
      nixconf = "$EDITOR ~/dotfiles/nixos-config/flake.nix";
      nixapps = "$EDITOR ~/dotfiles/nixos-config/home/gab/packages.nix";
      nixsys = "$EDITOR ~/dotfiles/nixos-config/modules/system/core.nix";
      nixcheck = "nix --extra-experimental-features 'nix-command flakes' flake check --no-build ~/dotfiles/nixos-config";
      up = "sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config";
      # Docker (resgatados do dotfile antigo)
      docker-start = "echo 'Iniciando o docker chefe'; sudo systemctl start docker";
      docker-stop = "echo 'Parando o docker'; sudo systemctl stop docker";
      docker-status = "systemctl status docker";
      docker-restart = "echo 'Reiniciando o docker...'; sudo systemctl restart docker";
      docker-ps-no-port = "docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}\t{{.Names}}'";
      sshd-start = "echo 'Iniciando o sshd chefe'; sudo systemctl start sshd";
      sshd-stop = "echo 'Parando o sshd'; sudo systemctl stop sshd";
      sshd-status = "systemctl status sshd";
      cat = "bat --style=plain";
      tmux-help = "bat --style=plain --paging=always ~/.config/tmux/cheatsheet.txt";
    };

    functions = {
      # tmux: anexa à sessão 'main' (cria se não existir)
      tm = {
        description = "tmux: anexa à sessão 'main' ou cria";
        body = "tmux new-session -A -s main";
      };

      rebuild = {
        description = "Aplica o flake versionado (switch + reload + restart shell)";
        body = ''
          sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config#nixos
          and hyprctl reload
          and systemctl --user restart caelestia
        '';
      };

      update = {
        description = "Só atualiza os inputs do flake (default: nixpkgs; 'update all' = todos). Aplica com rebuild";
        body = ''
          if test "$argv[1]" = "all"
            nix flake update --flake ~/dotfiles/nixos-config
          else
            nix flake update nixpkgs --flake ~/dotfiles/nixos-config
          end
        '';
      };

      dns = {
        description = "Troca DNS via nmcli: dns [cloudflare|google|quad9|automatic|status]";
        body = ''
          set connection (nmcli -g GENERAL.CONNECTION device show 2>/dev/null | head -n 1)

          if test -z "$connection" -o "$connection" = "--"
            echo "Nenhuma conexão ativa encontrada."
            return 1
          end

          switch "$argv[1]"
            case cloudflare
              set servers "1.1.1.1 1.0.0.1"
            case google
              set servers "8.8.8.8 8.8.4.4"
            case quad9
              set servers "9.9.9.9 149.112.112.112"
            case automatic
              sudo nmcli connection modify "$connection" \
                ipv4.ignore-auto-dns no ipv4.dns ""
              and sudo nmcli connection up "$connection"
              return
            case status
              nmcli device show | grep -E 'GENERAL.CONNECTION|IP4.DNS'
              return
            case '*'
              echo "Uso: dns [cloudflare|google|quad9|automatic|status]"
              return 1
          end

          sudo nmcli connection modify "$connection" \
            ipv4.dns "$servers" ipv4.ignore-auto-dns yes

          and sudo nmcli connection up "$connection"
        '';
      };

      cli = {
        description = "Abre um agente CLI: cli [claude|opencode|google|copilot] [args...]";
        body = ''
          set -l alvo $argv[1]
          set -e argv[1]
          set -l uso "Uso: cli [claude|opencode|google|copilot] [args...]"

          # Valida antes de chamar: mensagem clara se o agente não estiver instalado.
          function __cli_run
            if not command -q $argv[1]
              echo "cli: '$argv[1]' não encontrado no PATH (instale ou use outro agente)" >&2
              return 127
            end
            $argv
          end

          switch "$alvo"
            case claude
              __cli_run claude $argv
            case opencode
              __cli_run opencode $argv
            case google antigravity agy
              __cli_run agy $argv
            case copilot gh-copilot
              __cli_run copilot $argv
            case ''' -h --help help
              echo $uso
              return 0
            case '*'
              echo $uso >&2
              return 1
          end
          functions -e __cli_run
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
