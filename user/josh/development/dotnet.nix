{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      ms-dotnettools.csharp
    ];
  };
}
