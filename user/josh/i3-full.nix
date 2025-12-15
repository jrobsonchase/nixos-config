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
    ../josh/doom
  ];

  xsession.windowManager.i3.enable = true;

  home.packages = with pkgs; [
  ];
}
