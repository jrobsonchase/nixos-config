{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
