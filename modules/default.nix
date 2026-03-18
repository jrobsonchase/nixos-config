{ self, inputs, ... }:
let
  hosts = { };

  users = [ "josh" ];

  lib = import ../lib {
    inherit
      hosts
      users
      inputs
      self
      ;
  };

  inherit (lib)
    genNixosHydraJobs
    genHomeManagerHydraJobs
    ;
  inherit (builtins) foldl';

  overlay = import ../overlay {
    inherit inputs lib;
  };
in
{
  systems =
    lib.pipe hosts [
      builtins.attrValues
      (map (h: h.system))
    ]
    ++ [
      "x86_64-linux"
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
      pkgs = self.legacyPackages.${system};
    in
    {
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
