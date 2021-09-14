{ config, lib, pkgs, ... }:
{
  imports = [
    ./rust.nix
    ./nix.nix
  ];

  home.packages = with pkgs; [
    fira-code
    font-awesome
    aegyptus

    vim_configurable
    vscode
    ripgrep
    awscli

    clang
  ];
}
