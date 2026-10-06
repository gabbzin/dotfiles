# Sistema base. Espelho do antigo /etc/nixos/configuration.nix, sem mudar comportamento.
# Etapa 1: só reorganiza. Customizações entram nas próximas etapas.
{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";

  virtualisation.docker.enable = true;

  users.users."gab" = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.fish;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time 0 --remember --remember-session --user gab --cmd \"uwsm start hyprland-uwsm.desktop\"";
        user = "greeter";
      };
    };
  };

  programs.nix-ld.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  programs.dconf.enable = true;

  # gpu-screen-recorder exige cap_sys_admin no gsr-kms-server (store é
  # read-only: setcap direto impossível). Wrapper com a capability.
  security.wrappers.gsr-kms-server = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+ep";
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  
  fonts.packages = with pkgs; [
    material-symbols
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    cascadia-code
  ];

  
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    vim
    vscode
    spotify
    brave
    wget
    zed-editor
    fastfetch
    zip
    btop
    curl
    git
    unzip
    hyprlauncher
    hyprpolkitagent
    hyprpicker
    fuzzel
    libnotify
    trash-cli # trash-empty 30 (execs.lua)
    bibata-cursors # cursor (cursorTheme no hypr-vars.lua)
    adwaita-icon-theme # ícones dos .desktop (launcher)
    papirus-icon-theme # ícones de apps (workspaces/barra) — cobre Spotify/Brave/Kitty/VSCode
    gh
    powertop # caça-gastadores de bateria
    gpu-screen-recorder # backend do `caelestia record` (SUPER+ALT+R)
    reaper
    anydesk
    docker

    # Prompt de nome ao abrir kitty (SUPER+Return): Enter vazio = padrão, Esc = cancela.
    # Fixa o nome na ABA via fish_title (o fish sobrescreveria --title sozinho).
    (pkgs.writeShellScriptBin "kitty-title" ''
      t=$(fuzzel --dmenu --prompt "nome: " < /dev/null) || exit 0
      t=$(printf '%s' "$t" | tr -cd '[:alnum:] _-')
      if [ -z "$t" ]; then exec kitty; fi
      exec kitty --title "$t" fish -C "function fish_title; echo $t; end"
    '')
  ];
}
