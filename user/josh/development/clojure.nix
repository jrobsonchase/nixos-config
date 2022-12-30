{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    leiningen
    # clojure
    # clojure-lsp
  ];
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; with pkgs.vscode-utils; [
      (buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "clojure";
          publisher = "avli";
          version = "0.13.1";
          sha256 = "sha256-qL8XUQiADxMNF+suFj7ItXdeTEvKc1Xce4ndfi49AeI=";
        };
      })
    ];
  };
}
