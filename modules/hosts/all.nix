{ self, ... }:
let
  inherit (self) lib;
  hosts = lib.pipe (lib.readDir ./.) [
    lib.attrsToList
    (lib.filter (e: e.value == "directory"))
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
