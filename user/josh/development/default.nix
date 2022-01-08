{ config, lib, pkgs, ... }:
{
  imports = [
    ./rust.nix
    ./rune.nix
    ./go.nix
    ./dotnet.nix
    ./nix.nix
    ./vscode.nix
    ./c_cpp.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    awscli

    vim_configurable
  ];
}
