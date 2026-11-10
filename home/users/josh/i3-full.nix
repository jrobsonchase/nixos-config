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

  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
