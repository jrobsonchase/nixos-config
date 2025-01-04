{ config, lib, pkgs, inputModules, ... }:
{
  imports = [
    ../common.nix
    ./gpg.nix
    ./git.nix
    ./jujutsu
    ./development
    ./development/vscode.nix
    ./zellij.nix

    # inputModules.private.default
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
    htop
    zip
    unzip
    dnsutils
    wget
    mtr
    mosh
    ripgrep
    openssh
    mosh

    slack
    spotify
    zoom-us
    keepassxc
  ] ++ (lib.optionals pkgs.hostPlatform.isDarwin [
    xquartz
  ]) ++ (lib.optionals pkgs.hostPlatform.isLinux [
    usbutils
    inetutils
  ]);

  services = {
    syncthing = {
      enable = true;
    };
  };
}
