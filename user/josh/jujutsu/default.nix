{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      ui = {
        diff.format = "git";
        default-command = "default-alias";
        diff-editor = ":builtin";
        log-word-wrap = true;
      };
      aliases = {
        # Indirection since default-command doesn't accept args
        default-alias = [ "log" "-T" "log_oneline" ];
        l = [ "log" "-T" "log_comfortable" ];
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
    } // (import ./templates.nix);
  };
}
