{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop
    ./gpg.nix
    ./git.nix
    ./firefox.nix
    ./development
  ];

  nixpkgs.config.allowUnfree = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    wireshark
    nmap-graphical

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
    libreoffice-fresh

    xfce.thunar

    appimage-run

    nixosFlake
    hmFlake

    # aseprite-unfree

    cachix

    zoom-us
  ];
}
