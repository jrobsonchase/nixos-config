inputs@{ pkgs, lib, ... }:

let
  inherit (builtins) listToAttrs mapAttrs;
  inherit (lib) mapAttrsToList;

  nixosModule = import ./cachix.nix inputs;
  droidWrap = cacheFile:
    let
      modAttrs = import cacheFile;
      renameCacheKeys = name:
        if name == "binaryCaches" then "substituters"
        else if name == "binaryCachePublicKeys" then "trustedPublicKeys"
        else name;
    in
    {
      nix = listToAttrs (mapAttrsToList
        (name: value: {
          name = renameCacheKeys name;
          inherit value;
        })
        modAttrs.nix);
    };
  imports = map droidWrap nixosModule.imports;
in
{
  inherit imports;
}
