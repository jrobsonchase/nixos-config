{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
  ];

  programs.vscode = {
    profiles.default.extensions =
      with pkgs.vscode-extensions;
      with pkgs.vscode-utils;
      [
        # pdesaulniers.vscode-teal
      ];
  };
}
