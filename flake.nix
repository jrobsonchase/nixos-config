{
  inputs = {
    # Upstream package flakes
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Helper utilities
    flake-utils.url = "github:numtide/flake-utils";

    # NUR overlay
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Individual applications
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };

    # secret secret
    private.url = "git+ssh://github.com/jrobsonchase/nixos-private";
  };
  outputs =
    { self, ... }@inputs:
    let
      sysPkgs = inputs.nixos-unstable;
      usrPkgs = inputs.nixpkgs-unstable;

      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
      };

      users = [ "josh" ];

      lib = import ./lib {
        inherit hosts users inputs;
        lib = sysPkgs.lib;
      };

      inherit (sysPkgs.lib) nixosSystem;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (lib) genUsers genHosts getModules liftAttr;

      inputModules = liftAttr "nixosModules" inputs;

      overlay = import ./overlay {
        inherit inputs lib;
      };

      pkgsFor = pkgs: system: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay
          inputs.nur.overlay
        ];
      };
    in
    {
      nixosConfigurations = genHosts (
        { hostname, system, ... }:
        nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputModules;
          };
          pkgs = pkgsFor sysPkgs system;
          modules = [
            {
              nix.registry = {
                pkgs.flake = self;
                nixpkgs.flake = inputs.nixpkgs-unstable;
              };
            }
            ./host/common.nix
            ./host/${hostname}/default.nix
          ];
        }
      );

      homeConfigurations = genUsers (
        { username, system, ... }:
        homeManagerConfiguration {
          inherit system username;
          pkgs = pkgsFor usrPkgs system;
          homeDirectory = "/home/${username}";
          stateVersion = "21.11";
          extraModules = [ ./user/common.nix ];
          configuration = ./user/${username}/default.nix;
        }
      );

    } // inputs.flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = pkgsFor usrPkgs system;
    });
}
