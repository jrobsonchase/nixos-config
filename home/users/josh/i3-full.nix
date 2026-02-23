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

  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
