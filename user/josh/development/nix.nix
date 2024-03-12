{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nixpkgs-fmt
    nixfmt
    nil
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
