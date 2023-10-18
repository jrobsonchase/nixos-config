{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    hunspell
    hunspellDicts.en_US-large
  ];
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      vscodevim.vim
      oderwat.indent-rainbow
      eamodio.gitlens
      redhat.vscode-yaml
      ms-kubernetes-tools.vscode-kubernetes-tools
      streetsidesoftware.code-spell-checker
    ];
  };
}
