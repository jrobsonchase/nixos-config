{ config, lib, pkgs, ... }:
{
  imports = [
    ./rust.nix
    ./go.nix
    ./dotnet.nix
    ./nix.nix
    ./vscode.nix
    ./c_cpp.nix
  ];

  home.packages = with pkgs; [
    fira-code
    font-awesome
    aegyptus

    ripgrep
    awscli

    vim_configurable
  ];
}
