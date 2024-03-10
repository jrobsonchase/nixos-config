{
  inputs = {
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay
    fenix = {
      url = "github:nix-community/fenix";
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
      };
    };

    mudrs-milk = {
      url = "gitlab:mud-rs/milk/main";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    ngrok = {
      url = "github:ngrok/ngrok-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rpi5 = {
      url = "gitlab:jrobsonchase/nix-rpi5/flake-improvements";
    };
  };

  outputs = { self, flake-utils, nixpkgs, private, ... }@inputs:
    let
      hosts = {
        pi = {
          system = "aarch64-linux";
        };
        tarvos = {
          system = "x86_64-linux";
        };
        rhea = {
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
      inherit (lib) genUsers genHosts getModules liftAttr genNixosHydraJobs genHomeManagerHydraJobs;
      inherit (builtins) foldl';

      inputModules = liftAttr "nixosModules" inputs // {
        vscode-server = import inputs.vscode-server;
      };
      inputHomeModules = liftAttr "homeManagerModules" inputs;

      overlay = import ./overlay {
        inherit inputs lib;
      };

      pkgsFor = system: if system == "aarch64-linux" then (import inputs.nixpkgs {
        system = "x86_64-linux";
        crossSystem = {
          config = "aarch64-linux";
        };
        config.allowUnfree = true;
        overlays = [
          overlay
          inputs.fenix.overlays.default
        ];
      }) else (import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay
          inputs.fenix.overlays.default
        ];
      });
    in
    {
      hydraJobs = foldl' (a: b: a // b) { } [
        (genNixosHydraJobs self.nixosConfigurations)
        (genHomeManagerHydraJobs self.homeConfigurations)
      ];
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
          modules = [ ./droid ];
          pkgs = pkgsFor "aarch64-linux";
        };
      };


    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor system; in
      {
        legacyPackages = pkgs;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cachix
            home-manager
            jq
            nix
            nixos-rebuild
            sops
          ];
        };
      });
}
