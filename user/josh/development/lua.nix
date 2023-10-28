{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
      pdesaulniers.vscode-teal
    ];
  };
}
