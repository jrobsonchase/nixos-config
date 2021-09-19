{ config, lib, pkgs, ... }:
{
  imports = [
    ./desktop.nix
    ./gpg.nix
    ./git.nix
    ./firefox.nix
    ./development
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      enableFlakes = true;
    };
  };

  home.packages = with pkgs; [
    wireshark
    nmap-graphical

    stow
    tree
    file
    usbutils
    htop
    zip
    unzip

    slack
    discord
    spotify

    appimage-run

    evince

    mumble

    nixosFlake
  ];
}
