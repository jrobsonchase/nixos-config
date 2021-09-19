{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    private.url = "git+ssh://git@github.com/jrobsonchase/nixos-private?ref=main";
  };
  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
      };

      users = [ "josh" ];

      lib = import ./lib.nix {
        inherit hosts users;
        nixpkgs = inputs.nixpkgs;
      };

      inherit (inputs.nixpkgs.lib) nixosSystem;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (lib) genUsers genHosts getModules liftAttr;

      inputModules = liftAttr "nixosModules" inputs;
      inputPackages = liftAttr "packages" inputs;

      overlay = import ./overlay.nix {
        inherit inputPackages lib;
      };

      pkgsFor = system: import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
    in
    {
      nixosConfigurations = genHosts (
        { hostname, system, ... }:
        let
          hostSpecific = import ./host/${hostname};
        in
        nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputModules;
          };
          pkgs = pkgsFor system;
          modules = [
            { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
            ./host/common.nix
            hostSpecific
          ];
        }
      );

      homeConfigurations = genUsers (
        { username, system, ... }:
        homeManagerConfiguration {
          inherit system username;
          pkgs = pkgsFor system;
          homeDirectory = "/home/${username}";
          stateVersion = "21.11";
          extraModules = [ (import ./user/common.nix) ];
          configuration = import ./user/${username};
        }
      );
    };
}
