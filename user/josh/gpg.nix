{ config, lib, pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;
  };
  home.packages = with pkgs; [
    gnupg
  ];
}
