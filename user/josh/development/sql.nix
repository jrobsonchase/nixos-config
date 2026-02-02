{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nodejs
  ];
  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # mtxr.sqltools
      # mtxr.sqltools-driver-sqlite
    ];
  };
}
