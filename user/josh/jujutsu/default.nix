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
        default-alias = [ "log" "-T" "log_oneline" ];
        l = [ "log" "-T" "log_oneline" ];
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
    } // (import ./templates.nix);
  };
}
