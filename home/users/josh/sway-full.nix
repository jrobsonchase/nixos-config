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
    self.homeModules.desktop
    self.homeModules.development-all
  ];

  wayland.windowManager.sway.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
