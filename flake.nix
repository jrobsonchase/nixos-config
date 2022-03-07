{
  inputs = {
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-patched.url = "github:NixOS/nixpkgs/ffdadd3ef9167657657d60daf3fe0f1b3176402d";

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Helper utilities
    flake-utils.url = "github:numtide/flake-utils";

    # NUR overlay
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Individual applications
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
      };

      users = [ "josh" ];

      lib = import ./lib {
        inherit (inputs.nixpkgs) lib;
        inherit hosts users inputs;
      };

      inherit (inputs.nixpkgs.lib) nixosSystem;
      inherit (inputs.home-manager.lib) homeManagerConfiguration;
      inherit (inputs.nix-on-droid.lib) nixOnDroidConfiguration;
      inherit (lib) genUsers genHosts getModules liftAttr;

      inputModules = liftAttr "nixosModules" inputs;
      inputHomeModules = liftAttr "homeModules" inputs;

      overlay = import ./overlay {
        inherit inputs lib;
      };

      pkgsFor = system: import inputs.nixpkgs {
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
          pkgs = pkgsFor system;
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
          pkgs = pkgsFor system;
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
          pkgs = pkgsFor system;
        };
      };


    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor system; in
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
