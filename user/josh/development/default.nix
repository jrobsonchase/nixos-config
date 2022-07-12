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
    ./clojure.nix
  ];

  home.packages = with pkgs; [
    helix
    ripgrep
    awscli

    vim_configurable
  ];
}
