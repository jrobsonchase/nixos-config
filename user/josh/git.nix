{ config, lib, pkgs, ... }:
{
  services.keybase.enable = true;

  programs.git = {
    enable = true;
    userName = "Josh Robson Chase";
    userEmail = "josh@robsonchase.com";
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset %C(green)%G?%Creset%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    extraConfig = {
      rerere.enabled = true;
      tag.forceSignAnnotated = true;
      protocol.keybase.allow = "always";
      init.defaultBranch = "main";
    };
    signing = {
      signByDefault = true;
      key = null;
    };
  };

  home.packages = with pkgs; [
    keybase-gui
    kbfs
  ];
}
