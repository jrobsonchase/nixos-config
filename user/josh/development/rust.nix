{ config, lib, pkgs, ... }:
{
  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    CARGO_INSTALL_ROOT = "$HOME/.local";
  };
  home.packages = with pkgs; [
    rust-bindgen
    sccache
  ];

  # programs.vscode = {
  #   extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
  #     rust-lang.rust-analyzer-nightly
  #     a5huynh.vscode-ron
  #     serayuzgur.crates
  #     vadimcn.vscode-lldb
  #     tamasfe.even-better-toml
  #     rhaiscript.vscode-rhai
  #   ];
  # };
}
