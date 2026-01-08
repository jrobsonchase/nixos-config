{
  config,
  lib,
  pkgs,
  inputModules,
  ...
}:
{
  imports = [
    ../josh
    ../josh/desktop
    ../josh/development/all.nix
  ];

  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
    deskflow
  ];
}
