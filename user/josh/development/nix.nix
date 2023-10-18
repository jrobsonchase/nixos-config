{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    nixfmt
    rnix-lsp
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      mkhl.direnv
    ];
  };
}
