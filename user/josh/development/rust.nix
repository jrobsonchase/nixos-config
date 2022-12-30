{ config, lib, pkgs, ... }:
{
  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    CARGO_INSTALL_ROOT = "$HOME/.local";
  };
  home.packages = with pkgs; [
    # rustup
    # rust-analyzer
    cargo-edit
    rust-bindgen
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
      a5huynh.vscode-ron
      serayuzgur.crates
      vadimcn.vscode-lldb
    ];
  };
}
