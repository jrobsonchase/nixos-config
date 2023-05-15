{
  inputs = {
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    vscode-server = {
      url = "github:msteen/nixos-vscode-server/master";
      flake = false;
    };
    mudrs-milk = {
      url = "gitlab:mud-rs/milk/main";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
  };

  outputs = { self, private, ... }@inputs:
    let
      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
        hyperion = {
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

      inputModules = liftAttr "nixosModules" inputs // {
        vscode-server = import inputs.vscode-server;
      };
      inputHomeModules = liftAttr "homeManagerModules" inputs;

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
            ./host/${hostname}/default.nix
          ];
        }
      );

      homeConfigurations = genUsers (
        { username, system, ... }:
        homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = {
            inputModules = inputHomeModules;
          };
          modules = [
            {
              home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "21.11";
              };
            }
            ./user/common.nix
            ./user/${username}/default.nix
          ];
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
