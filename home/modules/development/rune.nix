{ pkgs, lib, ... }:
{
  home.packages = [
    # pkgs.runePackages.rune
  ];

  programs.vscode = {
    profiles.default.extensions = [
      # pkgs.runePackages.vscode-extension
    ];
  };
}
