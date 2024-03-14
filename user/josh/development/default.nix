{ config, lib, pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./vscode.nix
  ];
}
