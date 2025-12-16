{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
  ];
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      # redhat.vscode-yaml
      # ms-kubernetes-tools.vscode-kubernetes-tools
    ];
  };
}
