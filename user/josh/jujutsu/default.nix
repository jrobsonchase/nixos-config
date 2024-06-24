{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = pkgs.jujutsu.name;
      paths = [ pkgs.jujutsu ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/jj \
          --set LESS FRX
      '';
    };
    settings = {
      ui = {
        default-command = "default-alias";
        diff-editor = ":builtin";
        log-word-wrap = true;
      };
      aliases = {
        # Indirection since default-command doesn't accept args
        default-alias = [ "status" ];
        l = [ "log" "-T" "log_compact" ];
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
      experimental-advance-branches = {
        enabled-branches = [ "glob:*" ];
        disabled-branches = [ "main" ];
      };
      revsets = {
        # By default, log the trunk and all commits _not_ in trunk() that have a
        # visible head that's either tracked locally, or is in one of "my"
        # remote branches.
        log = "trunk() | ancestors(unmerged(visible_heads() ~ filtered_heads), 2)";
      };

      revset-aliases = {
        filtered_heads = "(remote_branches() ~ remote_branches(remote=origin)) | (notmy(remote_branches()) ~ branches())";
        gh-queue = "ancestors(remote_branches(gh-readonly-queue), 2)";
        "unmerged(x)" = "trunk()..x";
        "merged(x)" = "x & ::trunk()";
        "notmy(x)" = "x ~ mine()";
        "my(x)" = "x & mine()";
        "nottrunk(x)" = "x ~ trunk()";
      };

      aliases = {
        gh-queue = [ "l" "-r" "gh-queue" ];
      };

      git.auto-local-branch = false;
    } // (import ./templates.nix);
  };
}
