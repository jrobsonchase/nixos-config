{ config, lib, pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  home.packages = with pkgs; [
    gnupg
  ];
}
