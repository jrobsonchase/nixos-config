{ config, lib, pkgs, ... }:
{
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      # ms-vscode.cpptools
    ];
  };

  home.packages = with pkgs; [
    # gcc
    # binutils
    # clang
    # lldb
  ];
}
