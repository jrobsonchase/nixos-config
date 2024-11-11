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
      gregoire.dance
      ms-vscode-remote.remote-ssh
      ms-vsliveshare.vsliveshare
      oderwat.indent-rainbow
      eamodio.gitlens
      redhat.vscode-yaml
      ms-kubernetes-tools.vscode-kubernetes-tools
      streetsidesoftware.code-spell-checker
      signageos.signageos-vscode-sops
    ];
  };
}
