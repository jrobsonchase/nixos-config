{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private.url = "path:../nixos-private";
  };
  outputs = { self, nixpkgs, nixos-hardware, private, home-manager, ... }@inputs:
  let
    hosts = ["tarvos"];
  in
  {
    nixosConfigurations = nixpkgs.lib.genAttrs hosts (host:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixos-hardware private home-manager; };
        modules = [
          ({ ... }:
          {
            nix.registry.nixpkgs.flake = nixpkgs;
          })
          ./common.nix
          (./. + "/host/${host}/configuration.nix")
        ];
      }
    );
  };
}
