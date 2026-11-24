# Sistema base. Espelho do antigo /etc/nixos/configuration.nix, sem mudar comportamento.
# Etapa 1: só reorganiza. Customizações entram nas próximas etapas.
{ pkgs, lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel mais recente (amdgpu novo p/ Radeon 680M). Para voltar ao LTS, remover esta linha.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
  virtualisation.virtualbox.host.enable = true;

  users.users."gab" = {
    isNormalUser = true;
    description = "Gabriel";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "vboxusers"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.fish;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  
  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "ventoy-1.1.17"
      "ventoy-1.1.18"
    ];
  };

  programs.fish.enable = true;

  services.tailscale.enable = true;
  services.flatpak.enable = true;

  networking.firewall.checkReversePath = "loose";
  networking.firewall.allowedUDPPorts = [ 41641 ];
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

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

  # AnyDesk não assistido: daemon como root (o pacote nix não traz o service).
  # Após o switch: sudo anydesk --set-password (senha de acesso) e anota o ID.
  systemd.services.anydesk = {
    description = "AnyDesk";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.anydesk}/bin/anydesk --service";
      Restart = "on-failure";
      RestartSec = "5s";
    };
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
    vim # reserva: root/TTY sem home-manager
    git # root usa no rebuild (flake é repo git)
    curl
    wget
    anydesk # daemon root + `sudo anydesk --set-password`
    powertop # via sudo (secure_path não inclui o home)
    docker # daemon do sistema; CLI p/ todos
    # O pty.node (node-pty) do pacote vem sem libstdc++ no RUNPATH → o servidor
    # morre em loop e a janela nunca abre. Wrapper injeta a lib (sem rebuild).
    # (t3code é um symlinkJoin: overrideAttrs no postBuild é ignorado, por isso
    # embrulhamos num symlinkJoin nosso.)
    (symlinkJoin {
      name = "t3code-${t3code.version}";
      paths = [ t3code ];
      nativeBuildInputs = [ makeBinaryWrapper ];
      postBuild = ''
        for program in "$out/bin"/*; do
          wrapProgram "$program" --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
        done
      '';
    })
    antigravity-ide
    antigravity-cli
    bibata-cursors
    adwaita-icon-theme
  ];
}
