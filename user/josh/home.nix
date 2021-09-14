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

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [
    wireshark
    nmap-graphical

    stow
    tree
    file
    usbutils
    htop

    slack
    discord
    spotify

    appimage-run
  ];
}
