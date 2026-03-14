{
  config,
  lib,
  pkgs,
  inputModules,
  flakeModulesPath,
  ...
}:
{
  imports = [
    ./.
    (flakeModulesPath + "/desktop")
    (flakeModulesPath + "/development/all.nix")
  ];

  wayland.windowManager.sway.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
