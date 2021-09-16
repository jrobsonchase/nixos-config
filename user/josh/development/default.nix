{ config, lib, pkgs, ... }:
{
  imports = [
    ./rust.nix
    ./dotnet.nix
    ./nix.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [
    fira-code
    font-awesome
    aegyptus

    vim_configurable
    ripgrep
    awscli

    clang
    lldb
  ];
}
