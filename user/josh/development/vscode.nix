{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
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
      ms-kubernetes-tools.vscode-kubernetes-tools
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "code-spell-checker";
        publisher = "streetsidesoftware";
        version = "2.20.5";
        sha256 = "sha256-IR/mwEmiSPN/ZRiazclRSOie9RAjdNM0zXexVzImOs8=";
      }
    ];
  };
}
