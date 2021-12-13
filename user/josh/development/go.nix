{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    go_1_17
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      golang.go
    ];
  };
}
