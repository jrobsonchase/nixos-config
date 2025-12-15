{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixpkgs-fmt
  ];

  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
