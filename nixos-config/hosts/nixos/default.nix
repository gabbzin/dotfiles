# Host nixos: junta hardware + sistema + home-manager.
{ home-manager, caelestia-shell, claude-desktop, ... }:

{
  imports = [
    # Copiado de /etc/nixos/hardware-configuration.nix (gerado).
    # Atualizar com: sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/core.nix
    ../../modules/system/hardware.nix
    ../../modules/system/qylock.nix
    home-manager.nixosModules.default
    ../../home/gab/default.nix
  ];

  # Swapfile extra de 16 GiB; soma com a partição de ~8,8 GiB do
  # hardware-configuration.nix (~24,8 GiB no total). O NixOS cria o arquivo.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # MiB
    }
  ];

  # Mata o processo que mais usa memória quando RAM e swap estão quase no
  # fim, antes do sistema congelar (o OOM killer do kernel age tarde demais).
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # % de RAM livre
    freeSwapThreshold = 5; # % de swap livre
    enableNotifications = true;
    extraArgs = [
      # Nunca matar a sessão gráfica.
      "--avoid"
      "^(Hyprland|quickshell|caelestia-shell|systemd|sshd)$"
    ];
  };

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
