{
  config,
  lib,
  pkgs,
  ...
}:
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
  gitGet = pkgs.writeShellScript "git-get" ''
    #!/usr/bin/env bash

    URL=$1

    usage() {
    	cat << EOF
    Usage: git get <url>
    EOF
    	exit 1
    }

    malformed() {
    	cat << EOF
    Bad URL, expecting [<proto>://]<base_url>/<namespace>/<repository>[.git]
    EOF
    	exit 1
    }

    [ -z "''${URL}" ] && usage

    REPO_NAME="$(echo "''${URL}" | xargs basename -s .git)"
    NAMESPACE="$(echo "''${URL}" | xargs dirname | xargs basename)"
    BASE_URL="$(echo "''${URL}" | sed 's/^[a-zA-Z]*:\/\/\([a-zA-Z0-9]*@\)\?//' | xargs dirname | xargs dirname)"

    [ -z "''${REPO_NAME}" ] ||
    [ -z "''${NAMESPACE}" ] ||
    [ -z "''${BASE_URL}" ] ||
    [ "." == "''${BASE_URL}" ] && malformed

    DEST_DIR="''${HOME}/src/''${BASE_URL}/''${NAMESPACE}"
    DEST="''${DEST_DIR}/''${REPO_NAME}"

    mkdir -p "''${DEST_DIR}"
    git clone --recursive "''${URL}" "''${DEST}"
  '';
in
{
  programs.git = {
    enable = true;
    userName = "Josh Robson Chase";
    userEmail = "josh@robsonchase.com";
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset %C(green)%G?%Creset%C(yellow)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --abbrev-commit";
      mergebase = "!${mergebase} $*";
      get = "!${gitGet} $*";
    };
    extraConfig = {
      push.autoSetupRemote = true;
      rerere.enabled = true;
      tag.forceSignAnnotated = true;
      protocol.keybase.allow = "always";
      init.defaultBranch = "main";
      # url."git@github.com:".insteadOf = "https://github.com/";
      credential.helper = "store";
    };
    signing = {
      signByDefault = true;
      key = "E0C49F13ED752721F681535B92EB184D0CA433AD";
    };
  };
}
