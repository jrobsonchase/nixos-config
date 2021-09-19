{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    rust-analyzer
    rustup

    zlib
    binutils
    openssl
    pkgconfig
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      matklad.rust-analyzer
    ];
  };

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
