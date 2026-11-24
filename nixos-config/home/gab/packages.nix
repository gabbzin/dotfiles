# Pacotes de usuário. Flakes
{ pkgs, claude-desktop, ... }:

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
    wl-clipboard # copiar/colar no wayland (plugin yank do tmux)
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
    # Suíte de escritório: Writer (Word), Calc (Excel), Impress (PowerPoint).
    libreoffice
    m32edit
    android-studio
    android-tools
    spotify
    brave
    reaper
    fastfetch
    btop
    zip
    trash-cli
    gh
    heroic
    claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
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
    (pkgs.writeShellScriptBin "t3-nightly-update" ''
      set -eu
      env T3CODE_CHANNEL=nightly T3CODE_HOME="$HOME/.t3-nightly" \
          T3CODE_INSTALL_BIN_DIR="$HOME/.local/t3-nightly-bin" \
          sh <(curl -fsSL https://t3.codes/install.sh)
      ln -sfn "$HOME/.local/t3-nightly-bin/t3" "$HOME/.local/bin/t3-nightly"
      echo "Buscando a última nightly do desktop..."
      url="$(curl -fsSL 'https://api.github.com/repos/pingdotgg/t3code/releases?per_page=1' \
        | grep -o '"browser_download_url": *"[^"]*x86_64\.AppImage"' \
        | head -1 | sed 's/.*"\(https[^"]*\)".*/\1/')"
      [ -n "$url" ] || { echo "não achei AppImage nova"; exit 1; }
      curl -fSL -o "$HOME/Applications/T3-Code-Nightly.AppImage.new" "$url"
      chmod +x "$HOME/Applications/T3-Code-Nightly.AppImage.new"
      mv "$HOME/Applications/T3-Code-Nightly.AppImage.new" "$HOME/Applications/T3-Code-Nightly.AppImage"
      # Ícone do launcher sai de dentro do próprio AppImage.
      tmp="$(mktemp -d)"
      (cd "$tmp" && "$HOME/Applications/T3-Code-Nightly.AppImage" \
          --appimage-extract 'usr/share/icons/hicolor/512x512/apps/t3code.png' >/dev/null)
      mkdir -p "$HOME/.local/share/icons"
      cp "$tmp/squashfs-root/usr/share/icons/hicolor/512x512/apps/t3code.png" \
         "$HOME/.local/share/icons/t3code-nightly.png" || echo "aviso: ícone não extraído"
      rm -rf "$tmp"
      echo "OK: $(basename "$url")"
    '')
  ];

  home.sessionVariables = {
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
  };

  xdg.desktopEntries.t3code-nightly = {
    name = "T3 Code (Nightly)";
    comment = "Control plane p/ coding agents — canal nightly";
    # AppImage no NixOS precisa do FHS do appimage-run (senão: libglib não achada).
    # T3CODE_HOME separado: com o mesmo ~/.t3 da estável, uma derruba a outra.
    exec = "env T3CODE_HOME=/home/gab/.t3-nightly ${pkgs.appimage-run}/bin/appimage-run /home/gab/Applications/T3-Code-Nightly.AppImage %U";
    icon = "/home/gab/.local/share/icons/t3code-nightly.png";
    categories = [ "Development" ];
    startupNotify = true;
  };

  xdg.desktopEntries.nixos-rebuild = {
    name = "Rebuild NixOS";
    comment = "Aplica o flake versionado (switch + reload)";
    exec = "kitty --hold fish -c rebuild";
    icon = "system-software-update";
    categories = [ "System" ];
  };
}
