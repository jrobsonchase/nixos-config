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

  # extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
  #   (buildVscodeMarketplaceExtension {
  #     mktplcRef = {
  #       name = "clojure";
  #       publisher = "avli";
  #       version = "0.13.1";
  #       sha256 = "sha256-qL8XUQiADxMNF+suFj7ItXdeTEvKc1Xce4ndfi49AeI=";
  #     };
  #   })
  # ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
      matklad.rust-analyzer
      a5huynh.vscode-ron
      serayuzgur.crates
      vadimcn.vscode-lldb
      tamasfe.even-better-toml
      # (buildVscodeMarketplaceExtension {
      #   mktplcRef = {
      #     name = "cargo";
      #     publisher = "panicbit";
      #     version = "0.2.3";
      #     sha256 = "sha256-B0oLZE8wtygTaUX9/qOBg9lJAjUUg2i7B2rfSWJerEU=";
      #   };
      # })
    ];
  };
}
