# Caelestia = prioridade para Hyprland (base).
# Etapa 2 vai adicionar hypr-vars.lua (kitty, SUPER+D) + hypr-user.lua (atalhos resgatados).
{ caelestia-shell, pkgs, lib, ... }:

let
  # Settings base do shell (visual "default"). Cada variante de UI vira um JSON em
  # ~/.config/caelestia/variants/<nome>.json; o script `ui-variant` copia o escolhido
  # para ~/.config/caelestia/shell.json (arquivo gravável, não symlink da store).
  baseSettings = {
    # Barra: mostra só o nome do programa (último segmento após " - "),
    # em vez do título completo da janela.
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
    # Bluetooth: um ícone só. Ativo o Status da própria barra (abre popout de
    # conexões); o ícone de tray do blueman-applet fica escondido (o applet
    # continua rodando como agente de pareamento).
    bar.statusIcons = [
      { id = "lockStatus"; enabled = true; }
      { id = "audio"; enabled = false; }
      { id = "microphone"; enabled = false; }
      { id = "kbLayout"; enabled = false; }
      # Manter acordado (caffeine): id próprio deste fork, ver KeepAwakeStatus.qml.
      { id = "idleInhibitor"; enabled = true; }
      { id = "network"; enabled = true; }
      { id = "bluetooth"; enabled = true; }
      { id = "battery"; enabled = true; }
    ];
    bar.tray.hiddenIcons = [ "blueman" "blueman-tray" ];
    # TRIAGE crash do dashboard: aba de mídia religada a pedido; se o
    # SIGKILL voltar ao abrir o painel, o gatilho é o widget de mídia.
    dashboard.showMedia = true;
    # Dashboard religado (precisa do % da bateria); crash em investigação.
    dashboard.enabled = true;
    # Ocioso: os mesmos passos do padrão do Caelestia (bloqueia em 3 min, apaga a tela em 5),
    # mas a suspensão dos 10 min só vale na bateria. Na tomada, a tela bloqueia e apaga e os
    # processos seguem rodando. A lista substitui a padrão inteira, por isso repete as três etapas.
    general.idle.timeouts = [
      { timeout = 180; idleAction = "lock"; }
      { timeout = 300; idleAction = "dpms off"; returnAction = "dpms on"; }
      { timeout = 600; idleAction = [ "suspendThenHibernate" ]; inhibitWhenCharging = true; }
    ];
  };

  # Glass: superfícies do shell translúcidas (o Caelestia liga o blur do
  # caelestia-drawers sozinho quando transparency.enabled = true).
  glassSettings = lib.recursiveUpdate baseSettings {
    appearance.transparency = {
      enabled = true;
      base = 0.6;
      layers = 0.35;
    };
  };

  variants = {
    default = baseSettings;
    glass = glassSettings;
  };

  uiVariant = pkgs.writeShellApplication {
    name = "ui-variant";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = ''
      # ui-variant [default|glass|toggle|status]
      # "Reseta" a interface entre variantes: grava a escolha, troca o shell.json
      # do Caelestia e recarrega o Hyprland.
      state="$HOME/.local/state/caelestia/ui-variant"
      variants_dir="$HOME/.config/caelestia/variants"
      shell_json="$HOME/.config/caelestia/shell.json"

      current=default
      [ -r "$state" ] && current="$(head -n1 "$state")"

      cmd="''${1:-toggle}"
      case "$cmd" in
        status) echo "$current"; exit 0 ;;
        toggle) if [ "$current" = glass ]; then new=default; else new=glass; fi ;;
        *) new="$cmd" ;;
      esac

      if [ ! -f "$variants_dir/$new.json" ] || [ ! -f "$HOME/.config/hypr/variants/$new.lua" ]; then
        echo "variante desconhecida: $new" >&2
        echo -n "disponíveis:" >&2
        for f in "$variants_dir"/*.json; do b="$(basename "$f" .json)"; echo -n " $b" >&2; done
        echo >&2
        exit 1
      fi

      mkdir -p "$(dirname "$state")"
      printf '%s\n' "$new" > "$state"

      # Hyprland primeiro (o reload apaga regras de layer em runtime); depois o
      # shell.json, para o Caelestia reaplicar o que for dele. Escrita in-place
      # (mesmo inode) para não quebrar o file watcher do shell.
      hyprctl reload >/dev/null
      cat "$variants_dir/$new.json" > "$shell_json"

      notify-send -t 2000 "UI variant" "$new" || true
    '';
  };

  # Monitor principal: só ele recebe barra, painéis e exclusões de tela do shell; os
  # outros ficam "auxiliares" (só os apps, como no GNOME). Usa a config por monitor
  # do Caelestia (~/.config/caelestia/monitors/<nome>/shell.json), recarregada ao vivo.
  uiPrimary = pkgs.writeShellApplication {
    name = "ui-primary";
    runtimeInputs = [ pkgs.coreutils pkgs.jq pkgs.hyprland pkgs.libnotify ];
    text = ''
      # ui-primary [status|toggle|all|<monitor>|lid-close|lid-open|ensure]
      # lid-close/lid-open são chamados pelo atalho da tampa: ao fechar, a barra vai para
      # o monitor externo (se houver); ao abrir, volta ao que estava antes.
      # ensure é chamado pelo watcher (ui-primary-watch): se nenhum monitor conectado
      # estiver como principal (ex.: o externo que era principal foi desconectado),
      # devolve a barra para todos — sem isso a tela fica sem barra nenhuma.
      dir="$HOME/.config/caelestia/monitors"
      saved="$HOME/.local/state/caelestia/primary-before-lid"

      # "monitors all" inclui o notebook mesmo com a tampa fechada (monitor desligado).
      mapfile -t mons < <(hyprctl monitors all -j | jq -r '.[].name')
      [ "''${#mons[@]}" -gt 0 ] || { echo "nenhum monitor encontrado" >&2; exit 1; }

      is_aux() { grep -q '"enabled"[[:space:]]*:[[:space:]]*false' "$dir/$1/shell.json" 2>/dev/null; }

      current=()
      for m in "''${mons[@]}"; do is_aux "$m" || current+=("$m"); done

      cmd="''${1:-status}"
      case "$cmd" in
        status)
          if [ "''${#current[@]}" -eq "''${#mons[@]}" ]; then echo "all"; else echo "''${current[*]}"; fi
          exit 0 ;;
        toggle)
          # Passa para o próximo monitor depois do atual (se estiver em "all", vai para o primeiro).
          target="''${mons[0]}"
          if [ "''${#current[@]}" -eq 1 ]; then
            for i in "''${!mons[@]}"; do
              if [ "''${mons[$i]}" = "''${current[0]}" ]; then target="''${mons[$(( (i + 1) % ''${#mons[@]} ))]}"; fi
            done
          fi ;;
        ensure)
          # Nenhum monitor conectado é o principal (o principal foi desconectado):
          # devolve a barra para todos os conectados. Caso normal: não faz nada.
          [ "''${#current[@]}" -gt 0 ] && exit 0
          target="" ;;
        all) target="" ;;
        lid-close)
          # Primeiro monitor que não é a tela interna (eDP/LVDS/DSI); sem externo, não há o que mover.
          target=""
          for m in "''${mons[@]}"; do
            case "$m" in eDP*|LVDS*|DSI*) ;; *) [ -n "$target" ] || target="$m" ;; esac
          done
          [ -n "$target" ] || exit 0
          # Só guarda o estado anterior na primeira vez (evita sobrescrever se a tampa "pular").
          if [ ! -f "$saved" ]; then
            mkdir -p "$(dirname "$saved")"
            if [ "''${#current[@]}" -eq "''${#mons[@]}" ]; then echo all > "$saved"; else echo "''${current[0]:-all}" > "$saved"; fi
          fi ;;
        lid-open)
          [ -f "$saved" ] || exit 0
          target="$(head -n1 "$saved")"
          rm -f "$saved"
          [ "$target" != all ] || target="" ;;
        *) target="$cmd" ;;
      esac

      if [ -n "$target" ]; then
        found=0
        for m in "''${mons[@]}"; do [ "$m" = "$target" ] && found=1; done
        if [ "$found" -eq 0 ]; then
          if [ "$cmd" = lid-open ]; then
            target=""   # o monitor salvo sumiu (ex.: externo desconectado): volta para todos
          else
            echo "monitor desconhecido: $target (disponíveis: ''${mons[*]})" >&2
            exit 1
          fi
        fi
      fi

      for m in "''${mons[@]}"; do
        mkdir -p "$dir/$m"
        if [ -z "$target" ] || [ "$m" = "$target" ]; then
          printf '{\n}\n' > "$dir/$m/shell.json"
        else
          printf '{\n  "enabled": false\n}\n' > "$dir/$m/shell.json"
        fi
      done

      # Os workspaces acompanham o monitor principal: numerados vão para ele, o "ext"
      # (workspace do auxiliar, ver hyprland/rules.lua) vai para o outro monitor ativo.
      # Só roda com um principal definido ("all" não mexe em nada).
      if [ -n "$target" ]; then
        mapfile -t active < <(hyprctl monitors -j | jq -r '.[].name')
        other=""
        for m in "''${active[@]}"; do [ "$m" = "$target" ] || other="$m"; done
        if printf '%s\n' "''${active[@]}" | grep -qx "$target"; then
          while read -r id name; do
            if [ "$name" = ext ]; then
              [ -z "$other" ] || hyprctl dispatch "hl.dsp.workspace.move({ id = $id, monitor = \"$other\" })" >/dev/null
            else
              hyprctl dispatch "hl.dsp.workspace.move({ id = $id, monitor = \"$target\" })" >/dev/null
            fi
          done < <(hyprctl workspaces -j | jq -r '.[] | select(.name | startswith("special:") | not) | "\(.id) \(.name)"')
          # Devolve o foco ao principal, que é onde o usuário está trabalhando.
          hyprctl dispatch "hl.dsp.focus({ monitor = \"$target\" })" >/dev/null || true
        fi
      fi

      notify-send -t 2000 "Monitor principal" "''${target:-todos}" || true
    '';
  };
  # Atalho do "manter acordado" (SUPER+SHIFT+I): alterna o IdleInhibitor do Caelestia via IPC
  # e avisa o novo estado (a barra mostra o ícone, mas o aviso ajuda quando o jogo está em tela cheia).
  keepAwake = pkgs.writeShellApplication {
    name = "keep-awake";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = ''
      # keep-awake [toggle|on|off|status]
      ipc() { qs -c caelestia ipc call idleInhibitor "$@"; }
      case "''${1:-toggle}" in
        toggle) ipc toggle ;;
        on) ipc enable ;;
        off) ipc disable ;;
        status) ipc isEnabled; exit 0 ;;
        *) echo "uso: keep-awake [toggle|on|off|status]" >&2; exit 1 ;;
      esac
      if [ "$(ipc isEnabled)" = true ]; then
        notify-send -t 2000 "Manter acordado" "ligado: a tela não bloqueia nem apaga" || true
      else
        notify-send -t 2000 "Manter acordado" "desligado: gerenciamento de energia normal" || true
      fi
    '';
  };

  # Watcher do ui-primary: se o monitor principal é desconectado, ninguém devolve a
  # barra pro monitor que sobrou (shell.json dele fica com "enabled": false) e a tela
  # fica sem barra nenhuma. Esse loop roda `ui-primary ensure` de tempos em tempos.
  uiPrimaryWatch = pkgs.writeShellApplication {
    name = "ui-primary-watch";
    runtimeInputs = [ pkgs.coreutils uiPrimary ];
    text = ''
      while true; do
        ui-primary ensure || true
        sleep 5
      done
    '';
  };
in
{
  imports = [ caelestia-shell.homeManagerModules.default ];

  home.stateVersion = "26.05";

  # Tema de ícones pro shell/apps (Quickshell resolve via dconf).
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = "Papirus";
    };
  };

  programs.caelestia = {
    enable = true;
    cli.enable = true;

    # Patch versionado: % da bateria no lugar do ícone (sem chave upstream).
    package = caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.overrideAttrs (old: {
      # Barra no topo na variante glass: diff nos arquivos do upstream (BarWrapper, ContentWindow,
      # Exclusions, Interactions, Panels, Regions). Se o upstream mexer neles, o build falha
      # avisando em vez de aplicar errado; aí é só regerar o patch (ver files/caelestia/).
      patches = (old.patches or [ ]) ++ [ ../../files/caelestia/topbar.patch ];

      postPatch = (old.postPatch or "") + ''
        # Arquivos novos da barra do topo (a seleção da variante vem de ~/.local/state/caelestia/ui-variant).
        cp ${../../files/caelestia/UiVariant.qml} services/UiVariant.qml
        cp ${../../files/caelestia/TopBar.qml} modules/bar/TopBar.qml
        cp ${../../files/caelestia/TopWorkspaces.qml} modules/bar/components/TopWorkspaces.qml

        cp ${../../files/caelestia/BatteryStatus.qml} modules/bar/components/status/BatteryStatus.qml

        # Ícone "manter acordado" (caffeine) nos status da barra. A TopBar (glass) já traz o
        # delegate no arquivo próprio; na barra lateral o delegate entra logo após o `role: "id"`
        # (âncora de uma linha só; se o upstream mudar, --replace-fail derruba o build).
        cp ${../../files/caelestia/KeepAwakeStatus.qml} modules/bar/components/status/KeepAwakeStatus.qml
        substituteInPlace modules/bar/components/StatusIcons.qml \
          --replace-fail 'role: "id"' 'role: "id"
                DelegateChoice {
                    roleValue: "idleInhibitor"
                    delegate: EntryWrapper {
                        KeepAwakeStatus {
                            colour: root.colour
                        }
                    }
                }'

        # Monitor auxiliar (ui-primary): sem barra/painéis, mas COM papel de parede.
        # O wallpaper usava Screens.screens (já filtrada por `enabled`); passa a usar todas as telas.
        substituteInPlace modules/background/Background.qml \
          --replace-fail "model: Screens.screens.filter(" "model: Quickshell.screens.filter("
      '';
    });

    settings = baseSettings;
  };

  # shell.json deixa de ser symlink da store: vira arquivo gravável escolhido por variante.
  xdg.configFile = {
    "caelestia/shell.json".enable = lib.mkForce false;
  } // lib.mapAttrs' (name: settings:
    lib.nameValuePair "caelestia/variants/${name}.json" { text = builtins.toJSON settings; }
  ) variants;

  home.packages = [ uiVariant uiPrimary keepAwake ];

  # O plugin qtengine não chega ao Quickshell, então o Qt cairia no tema hicolor
  # (ícones de notificação quebrados). QS_ICON_THEME força o tema.
  systemd.user.services.caelestia.Service.Environment = [ "QS_ICON_THEME=Papirus-Dark" ];

  # Mantém a barra viva mesmo se o monitor principal sumir (ver uiPrimaryWatch).
  systemd.user.services.ui-primary-watch = {
    Unit = {
      Description = "Recoloca a barra num monitor conectado quando o principal some";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${uiPrimaryWatch}/bin/ui-primary-watch";
      Restart = "always";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # A cada rebuild, regrava o shell.json a partir da variante ativa (fonte da verdade = Nix).
  home.activation.caelestiaShellJson = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    state="$HOME/.local/state/caelestia/ui-variant"
    dir="$HOME/.config/caelestia"
    v=default
    [ -r "$state" ] && v="$(head -n1 "$state")"
    [ -f "$dir/variants/$v.json" ] || v=default
    if [ -L "$dir/shell.json" ]; then run rm -f "$dir/shell.json"; fi
    run sh -c "cat '$dir/variants/$v.json' > '$dir/shell.json'"
  '';
}
