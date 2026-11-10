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

  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
