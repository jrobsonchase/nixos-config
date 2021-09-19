{ config, lib, pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      ms-vscode.cpptools
    ];
  };
}
