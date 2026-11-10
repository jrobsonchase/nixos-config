{ self, ... }:
let
  inherit (self) lib;
  hosts = lib.pipe (lib.readDir ./.) [
    lib.attrsToList
    (lib.filter (e: e.value == "directory"))
    (lib.filter (
      e:
      let
        name = lib.removePrefix "_" e.name;
      in
      !(builtins.pathExists (./. + "/${name}.nix"))
    ))
    (lib.map (
      { name, ... }:
      {
        name = lib.removePrefix "_" name;
        value = lib.nixosSystem (./. + "/${name}");
      }
    ))
    lib.listToAttrs
  ];
in
{
  flake.nixosConfigurations = hosts;
}
