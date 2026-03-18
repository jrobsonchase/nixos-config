{
  inputs,
  ...
}:
let
  inherit (inputs) flake-schemas;
  schemas-lib = flake-schemas.lib;
in
{
  flake.schemas = flake-schemas.schemas // {
    # Prevent recursing into the legacyPackages output
    legacyPackages = flake-schemas.schemas.legacyPackages // {
      inventory = _: schemas-lib.mkChildren { };
    };
  };
}
