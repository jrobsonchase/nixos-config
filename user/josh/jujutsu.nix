{ config, lib, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      user = {
        name = "Josh Robson Chase";
        email = "josh@robsonchase.com";
      };
    };
  };
}
