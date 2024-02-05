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

      revset-aliases = {
        nonmain = "(branches() & ~main) | @";
      };
      revsets = {
        log = "ancestors((::main ~ ::nonmain) | (::nonmain ~ ::main), 2)";
      };

      git.auto-local-branch = false;
    } // (import ./templates.nix);
  };
}
