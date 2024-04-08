{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt
    nixpkgs-fmt
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
