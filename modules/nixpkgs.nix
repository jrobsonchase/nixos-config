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
    {
      # legacyPackages = import inputs.nixpkgs {
      #   inherit system;
      #   config = {
      #     allowUnfree = true;
      #   };
      #   overlays = [
      #     self.overlays.default
      #     inputs.fenix.overlays.default
      #     inputs.nix-rpi5.overlays.default
      #   ];
      # };
    };
}
