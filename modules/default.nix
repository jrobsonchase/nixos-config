{ self, inputs, ... }:
let
  hosts = {
    pi = {
      system = "aarch64-linux";
    };
    ymir = {
      system = "x86_64-linux";
    };
    fenrir = {
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

  lib = import ../lib {
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

  overlay = import ../overlay {
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
  systems = lib.pipe hosts [
    builtins.attrValues
    (map (h: h.system))
  ];
  flake = {
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
          inherit inputModules self;
          flakeModulesPath = self + "/nixos/modules";
          flakeSecretsPath = self + "/secrets";
        };
        pkgs = pkgsFor system;
        modules = [
          {
            nix.registry = {
              pkgs.flake = self;
              nixpkgs.flake = inputs.nixpkgs;
            };
          }
          ../nixos/hosts/${hostname}/default.nix
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
            inherit self;
            inputModules = inputHomeModules;
            flakeModulesPath = self + "/home/modules";
            myModulesPath = self + "/home/users/${username}/modules";
            flakeSecretsPath = self + "/secrets";
          };
          modules = [
            {
              home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "21.11";
              };
            }
            (self + "/home/users/${username}/hosts/${host}")
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
  };
  perSystem =
    { system, ... }:
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
    };
}
