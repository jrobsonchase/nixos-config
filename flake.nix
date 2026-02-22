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

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    };

    # Individual applications
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rpi5 = {
      url = "gitlab:jrobsonchase/nix-rpi5/flake-improvements";
    };

    zed = {
      url = "github:jrobsonchase/zed/devel";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      private,
      ...
    }@inputs:
    let
      hosts = {
        pi = {
          system = "aarch64-linux";
        };
        ymir = {
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
      inherit (lib)
        genUsers
        genHosts
        liftAttr
        genNixosHydraJobs
        genHomeManagerHydraJobs
        ;
      inherit (builtins) foldl';

      inputModules = liftAttr "nixosModules" inputs;
      inputHomeModules = liftAttr "homeManagerModules" inputs;

      overlay = import ./overlay {
        inherit inputs lib;
      };

      pkgsFor =
        system:
        import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            overlay
            inputs.fenix.overlays.default
            inputs.nix-rpi5.overlays.default
          ];
        };
    in
    {
      overlays.default = overlay;
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

      homeConfigurations =
        (genUsers (
          {
            username,
            system,
            host,
            ...
          }:
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
              (self + "/user/${username}@${host}")
            ];
          }
        ))
        // {
          josh = homeManagerConfiguration {
            pkgs = pkgsFor "aarch64-darwin";
            extraSpecialArgs = {
              inputModules = inputHomeModules;
            };
            modules = [
              {
                home = {
                  username = "josh";
                  homeDirectory = "/Users/josh";
                  stateVersion = "21.11";
                };
              }
              (self + "/user/josh")
            ];
          };
        };

      nixOnDroidConfigurations = {
        device = nixOnDroidConfiguration {
          modules = [ ./droid ];
          pkgs = pkgsFor "aarch64-linux";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = pkgsFor system;
      in
      {
        legacyPackages = pkgs;
        formatter = pkgs.nixfmt;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            home-manager
            home-flake

            nixos-rebuild
            nixos-flake

            nixos-diff
            home-diff

            cachix

            helix
            sops
            jq
          ];
        };
      }
    );
}
