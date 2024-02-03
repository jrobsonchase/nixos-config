{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      ui = {
        default-command = "log";
        diff.format = "git";
        diff-editor = ":builtin";
        log-word-wrap = true;
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
    } // (import ./templates.nix);
  };
}
