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
    github-copilot-cli
  ];
}
