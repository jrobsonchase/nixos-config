{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
  ];

  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
