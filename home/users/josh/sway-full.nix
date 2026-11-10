{
  config,
  lib,
  pkgs,
  self,
  inputModules,
  flakeModulesPath,
  ...
}:
{
  imports = [
    ./.
    (flakeModulesPath + "/desktop")
    self.homeModules.development-all
  ];

  wayland.windowManager.sway.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
