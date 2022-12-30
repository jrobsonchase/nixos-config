{ config, lib, pkgs, ... }:
let
  mergebase = pkgs.writeShellScript "mergebase" ''
    #!/usr/bin/env bash
    set -euf -o pipefail

    base=''${1:-origin/master}
    shift || true # don't fail if no args were passed
    export GIT_OPTIONAL_LOCKS=0

    git branch -D tmp/mergebase 2>&1 >/dev/null || true
    git checkout -b tmp/mergebase $base
    git merge --no-edit --into-name $base $*
    git checkout -
    git rebase tmp/mergebase
    git branch -D tmp/mergebase
  '';
in
{
  services.keybase.enable = true;

  programs.git = {
    enable = true;
    userName = "Josh Robson Chase";
    userEmail = "josh@robsonchase.com";
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset %C(green)%G?%Creset%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit";
      mergebase = "!${mergebase} $*";
    };
    extraConfig = {
      push.autoSetupRemote = true;
      rerere.enabled = true;
      tag.forceSignAnnotated = true;
      protocol.keybase.allow = "always";
      init.defaultBranch = "main";
      # url."git@github.com:".insteadOf = "https://github.com/";
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
