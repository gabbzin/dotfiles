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

  users.users."gab" = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [
      "networkmanager"
      "wheel"
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

  # Keyring + dconf (gsettings) exigidos pelo autostart do Hyprland (execs.lua).
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  # Fontes do sistema: Material Symbols (ícones da barra) + JetBrainsMono NF
  # (fonte padrão da UI do shell). Sem elas o quickshell cai em fallback.
  fonts.packages = with pkgs; [
    material-symbols
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
  ];

  # TODO Etapa 4: mover apps de usuário (vscode, zed, spotify, brave)
  # para home/gab/packages.nix. Mantidos aqui na Etapa 1 para não quebrar.
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    vim
    vscode # binário; perfis+extensões gerenciados pelo próprio VSCode (editors.nix)
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
    # Exigidos pelos binds/autostart do Hyprland Caelestia (Etapa 2)
    hyprpolkitagent # agente polkit (execs.lua)
    hyprpicker # SUPER+SHIFT+C color picker
    fuzzel # clipboard/emoji/launcher do caelestia CLI
    libnotify # notify-send (bind de teste)
    trash-cli # trash-empty 30 (execs.lua)
    bibata-cursors # cursor (cursorTheme no hypr-vars.lua)
    adwaita-icon-theme # ícones dos .desktop (launcher)
    gh # GitHub CLI (auth pra abrir issue upstream)
    reaper
    anydesk
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
