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
  # nixpkgs.overlays = [
  #   (self: super: {
  #     discord = super.discord.overrideAttrs (_: {
  #       src = builtins.fetchTarball {
  #         url = "https://discord.com/api/download/stable?platform=linux&format=tar.gz";
  #         sha256 = "sha256:05s7irhw984slalnf7q5rps9i8izq542lnman9s1x6csd26r157s";
  #       };
  #     });
  #   })
  # ];

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

    sweethome3d.application
    geeqie
    slack
    discord
    spotify
    mumble
    evince
    darktable

    xfce.thunar

    appimage-run

    nixosFlake
    hmFlake

    aegyptus

    # aseprite-unfree

    cachix

    zoom-us
  ];
}
