{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ./desktop
    ./gpg.nix
    ./git.nix
    ./firefox.nix
    ./development

    inputModules.private.defaultModule
  ];

  nixpkgs.config.allowUnfree = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    wireshark
    nmap

    jq
    stow
    tree
    bc
    file
    usbutils
    htop
    zip
    unzip
    dnsutils
    wget
    mtr
    screen

    sweethome3d.application
    geeqie
    slack
    discord
    spotify
    mumble
    evince
    darktable
    yubioath-desktop
    libreoffice-fresh
    mudrs-milk
    teams

    xfce.thunar

    appimage-run

    # aseprite-unfree

    zoom-us
  ];
}
