{ pkgs, lib, ... }:
{
  home.packages = [
    # pkgs.runePackages.rune
  ];

  programs.vscode = {
    extensions = [
      # pkgs.runePackages.vscode-extension
    ];
  };
}
