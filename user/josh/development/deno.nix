{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    deno
  ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      denoland.vscode-deno
    ];
  };
}
