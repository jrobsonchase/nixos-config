{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nix, nixpkgs }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ...}: {
          nix.registry.nixpkgs.flake = nixpkgs;
        })
        ./nixos-configuration.nix
      ];
    };
  };
}
