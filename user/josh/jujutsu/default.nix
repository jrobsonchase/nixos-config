{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      ui = {
        default-command = "log";
      };
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
    } // (import ./templates.nix);
  };
}
