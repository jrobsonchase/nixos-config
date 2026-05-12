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

  programs.opencode = {
    enable = true;
  };

  home.packages = with pkgs; [
    bun
    nodejs
  ];
}
