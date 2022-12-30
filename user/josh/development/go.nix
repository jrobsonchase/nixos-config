{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    # go_1_19
  ];

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/bin"
  ];

  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      golang.go
    ];
  };
}
