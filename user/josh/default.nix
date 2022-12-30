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
    inetutils
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
    # yubioath-flutter
    libreoffice-fresh
    mudrs-milk

    xfce.thunar

    appimage-run

    citrix
    # aseprite-unfree
    zoom-us
  ];
}
