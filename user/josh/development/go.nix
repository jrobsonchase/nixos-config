{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    go
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      golang.go
    ];
  };
}
