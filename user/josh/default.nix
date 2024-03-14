{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ../common.nix
    ./gpg.nix
    ./git.nix
    ./jujutsu
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    jq
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
    ripgrep
    vim_configurable
  ];
}
