{ self, inputs, ... }:
let
  hosts = {
    pi = {
      system = "aarch64-linux";
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

  inherit (lib)
    genNixosHydraJobs
    genHomeManagerHydraJobs
    ;
  inherit (builtins) foldl';

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
  systems =
    lib.pipe hosts [
      builtins.attrValues
      (map (h: h.system))
    ]
    ++ [
      "aarch64-darwin"
    ];
  flake = {
    inherit lib;
    overlays.default = overlay;
    hydraJobs = foldl' (a: b: a // b) { } [
      (genNixosHydraJobs self.nixosConfigurations)
      (genHomeManagerHydraJobs self.homeConfigurations)
    ];
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
