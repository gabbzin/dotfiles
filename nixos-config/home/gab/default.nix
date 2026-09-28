# Home do gab. Só importa os módulos. Otimização global de pkgs fica aqui.
{ caelestia-shell, ... }:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  home-manager.users.gab = {
    imports = [
      ./caelestia.nix
      ./hyprland.nix
      ./fish.nix
      ./kitty.nix
      ./nvim.nix
      ./editors.nix
      ./tools.nix
      ./packages.nix
    ];
  };

  home-manager.extraSpecialArgs = { inherit caelestia-shell; };
}
