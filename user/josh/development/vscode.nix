{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
  ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      vscodevim.vim
      denoland.vscode-deno
      redhat.java
    ];
  };
}
