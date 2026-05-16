{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./nix.nix
    ./helix.nix
  ];

  home.packages = with pkgs; [
    supernote-cli
  ];
}
