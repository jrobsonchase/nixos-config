{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (self.lib) genHosts liftAttr;

  inputModules = liftAttr "nixosModules" inputs;
in
{
  flake.nixosConfigurations = genHosts (
    { hostname, system, ... }:
    nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputModules self;
        flakeModulesPath = self + "/nixos/modules";
        flakeSecretsPath = self + "/secrets";
      };
      pkgs = self.legacyPackages.${system};
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
}
