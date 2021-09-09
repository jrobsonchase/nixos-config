{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    private.url = "path:../nixos-private";
  };
  outputs = { self, nixpkgs, nixos-hardware, ... }@inputs:
  let
    hosts = ["tarvos"];
  in
  {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixos-hardware; };
        modules = [
          ({ ... }:
          {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          ./nixos-configuration.nix
          (./. + "/hardware/${host}/hardware-configuration.nix")
        ] ++ inputs.private.nixosModules;
      }
    );
  };
}
