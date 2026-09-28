# Host nixos: junta hardware + sistema + home-manager.
{ home-manager, caelestia-shell, ... }:

{
  imports = [
    # Copiado de /etc/nixos/hardware-configuration.nix (gerado).
    # Atualizar com: sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
    ./hardware-configuration.nix
    ../../modules/system/core.nix
    ../../modules/system/hardware.nix
    home-manager.nixosModules.default
    ../../home/gab/default.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
