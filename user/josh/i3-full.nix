{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ../josh
    ../josh/desktop
    ../josh/development/all.nix

    inputModules.ngrok.ngrok
  ];

  xsession.windowManager.i3.enable = true;

  programs.ngrok = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    wireshark
    nmap

    slack
    discord
    spotify
    evince

    appimage-run

    zoom-us
  ];
}
