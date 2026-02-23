{
  config,
  lib,
  pkgs,
  ...
}:
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
        l = [
          "log"
          "-T"
          "builtin_log_compact"
        ];
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
      # experimental-advance-branches = {
      #   enabled-branches = [ "glob:*" ];
      #   disabled-branches = [ "main" ];
      # };
      revsets = {
        # By default, log the trunk and all commits _not_ in trunk() that have a
        # visible head that's either tracked locally, or is in one of "my"
        # remote branches.
        log = "trunk() | ancestors(unmerged(visible_heads() ~ filtered_heads), 2)";
      };

      revset-aliases = {
        filtered_heads = "(remote_bookmarks() ~ remote_bookmarks(remote=exact:origin)) | (notmy(remote_bookmarks()) ~ bookmarks())";
        gh-queue = "ancestors(remote_bookmarks(gh-readonly-queue), 2)";
        "unmerged(x)" = "trunk()..x";
        "merged(x)" = "x & ::trunk()";
        "notmy(x)" = "x ~ mine()";
        "my(x)" = "x & mine()";
        "nottrunk(x)" = "x ~ trunk()";
      };

      aliases = {
        gh-queue = [
          "l"
          "-r"
          "gh-queue"
        ];
      };

      git.auto-local-bookmark = false;
      remotes.origin.auto-track-bookmarks = "exact:main";

      signing = {
        behavior = "own";
        backend = "gpg";
        key = "E0C49F13ED752721F681535B92EB184D0CA433AD";
      };
    }
    // (import ./templates.nix);
  };
}
