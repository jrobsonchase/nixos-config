{
  inputs = {
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Helper utilities
    flake-utils.url = "github:numtide/flake-utils";

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
      url = "git+ssh://git@github.com/ngrok/ngrok-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, private, ngrok, ... }@inputs:
    let
      hosts = {
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
          inputs.fenix.overlays.default
        ];
      };
    in
    {
      hydraJobs = {
        tarvos = self.nixosConfigurations.tarvos.config.system.build.toplevel;
        rhea = self.nixosConfigurations.rhea.config.system.build.toplevel;
        josh = self.homeConfigurations."josh@rhea".activationPackage;
      };
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


    } // inputs.flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor system; in
      {
        legacyPackages = pkgs;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixVersions.nix_2_19
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
