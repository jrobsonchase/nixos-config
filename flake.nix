{
  inputs = {
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";

    # New version of nix with some fixes
    nix = {
      url = "github:NixOS/nix";
    };

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Helper utilities
    flake-utils.url = "github:numtide/flake-utils";

    # NUR overlay
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Individual applications
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/be-friendly-to-users";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };
    tokio-console = {
      url = "github:tokio-rs/console";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-utils.follows = "flake-utils";
      };
    };
    mudrs-milk = {
      url = "gitlab:mud-rs/milk/main";
    };
  };

  outputs = { self, private, ... }@inputs:
    let
      sysPkgs = inputs.nixos;
      usrPkgs = inputs.nixpkgs;

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
      inherit (inputs.nix-on-droid.lib) nixOnDroidConfiguration;
      inherit (lib) genUsers genHosts getModules liftAttr;

      inputModules = liftAttr "nixosModules" inputs;
      inputHomeModules = liftAttr "homeModules" inputs;

      overlay = import ./overlay {
        inherit inputs lib;
      };

      pkgsFor = pkgs: system: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay
          inputs.nur.overlay
          inputs.rust-overlay.overlay
          inputs.cargo2nix.overlay
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
                nixpkgs.flake = inputs.nixpkgs;
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
          extraSpecialArgs = {
            inputModules = inputHomeModules;
          };
          configuration = ./user/${username}/default.nix;
        }
      );

      nixOnDroidConfigurations = {
        device = nixOnDroidConfiguration rec {
          config = ./droid;
          system = "aarch64-linux";
          pkgs = pkgsFor usrPkgs system;
        };
      };


    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor usrPkgs system; in
      {
        legacyPackages = pkgs;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            home-manager
            nixos-rebuild
          ];
        };
      });
}
