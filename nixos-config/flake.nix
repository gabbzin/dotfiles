{
  description = "NixOS + Caelestia (modular, fonte em ~/dotfiles/nixos-config)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qylock = {
      url = "github:Darkkal44/qylock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      # Reempacota o .deb oficial da Anthropic (mantido, atualizado com frequência).
      url = "github:aaddrick/claude-desktop-debian";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      caelestia-shell,
      qylock,
      claude-desktop,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/default.nix
          qylock.nixosModules.default
        ];
        specialArgs = { inherit home-manager caelestia-shell claude-desktop; };
      };
    };
}
