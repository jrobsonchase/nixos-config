{ flakeModulesPath, pkgs, ... }:
{
  imports = [
    ../../sway-full.nix
  ];

  home.packages = with pkgs; [
    gh
  ];
}
