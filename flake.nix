{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private.url = "git+ssh://git@github.com/jrobsonchase/nixos-private";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs =
    { self
    , nixpkgs
    , nixos-hardware
    , private
    , home-manager
    , ...
    }:
    let
      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
      };

      users = [ "josh" ];

      lib = import ./lib.nix {
        inherit nixpkgs hosts users;
      };

      inherit (nixpkgs.lib) nixosSystem;
      inherit (home-manager.lib) homeManagerConfiguration;
      inherit (lib) genUsers genHosts;
    in
    {
      nixosConfigurations = genHosts (
        { hostname, system, ... }:
        nixosSystem {
          inherit system;
          specialArgs = {
            inherit nixpkgs nixos-hardware private;
          };
          modules = [
            ./common.nix
            (./. + "/host/${hostname}/configuration.nix")
          ];
        }
      );

      homeConfigurations = genUsers (
        { username, system, ... }:
        homeManagerConfiguration {
          inherit system username;
          homeDirectory = "/home/${username}";
          stateVersion = "21.05";
          configuration = import ./user/${username}/home.nix;
        }
      );
    };
}
