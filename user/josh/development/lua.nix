{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    luajitPackages.tl
    luajit
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
      pdesaulniers.vscode-teal
    ];
  };
}
