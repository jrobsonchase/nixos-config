{ self, inputs, ... }:
{
  flake.nixosModules.nixpkgs =
    { config, ... }:
    {
      nix.registry = {
        pkgs.flake = self;
        nixpkgs.flake = inputs.nixpkgs;
      };
      nixpkgs.overlays = [
        self.overlays.default
        inputs.fenix.overlays.default
      ];
      nixpkgs.config.allowUnfree = true;
    };

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          self.overlays.default
          inputs.fenix.overlays.default
        ];
      };
    in
    {
      legacyPackages = pkgs;
    };
}
