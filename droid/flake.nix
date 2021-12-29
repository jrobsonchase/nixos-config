{
  description = "nix-on-droid configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.url = "github:t184256/nix-on-droid";
    nix-on-droid.inputs.nixpkgs.follows = "nixpkgs";
    nix-on-droid.inputs.home-manager.follows = "home-manager";
  };

  outputs = { nix-on-droid, ... }: {
    nixOnDroidConfigurations = {
      device = nix-on-droid.lib.nixOnDroidConfiguration {
        config = ./nix-on-droid.nix;
        system = "aarch64-linux";
        extraModules = [
          # import source out-of-tree modules like:
          # flake.nixOnDroidModules.module
        ];
        extraSpecialArgs = {
          # arguments to be available in every nix-on-droid module
        };
        # your own pkgs instance (see nix-on-droid.overlay for useful additions)
        # pkgs = ...;
      };
    };
  };
}
