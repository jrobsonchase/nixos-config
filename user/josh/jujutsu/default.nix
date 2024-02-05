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

      revsets = {
        # By default, log the trunk and all commits _not_ in trunk() that have a
        # visible head that's either tracked locally, or is in one of "my"
        # remote branches.
        log = "trunk() | ancestors(trunk()..(visible_heads() ~ (remote_branches() ~ mine())), 2)";
      };

      git.auto-local-branch = false;
    } // (import ./templates.nix);
  };
}
