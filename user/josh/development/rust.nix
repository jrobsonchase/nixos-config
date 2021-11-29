{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo2nix
    rustup
    rust-analyzer
    cargo-edit
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
      a5huynh.vscode-ron
      serayuzgur.crates
    ];
  };
}
