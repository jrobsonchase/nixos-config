{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    enableBashIntegration = true;
    package = pkgs.symlinkJoin {
      name = pkgs.jujutsu.name;
      paths = [ pkgs.jujutsu ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/jj \
          --unset PAGER
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

      revsets = {
        log = "@ | ancestors(immutable_heads()..branches(), 2) | heads(immutable_heads())";
      };

      git.auto-local-branch = false;
    } // (import ./templates.nix);
  };
}
