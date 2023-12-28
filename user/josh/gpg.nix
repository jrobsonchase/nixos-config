{ config, lib, pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;
    pinentryFlavor = "qt";
  };
  home.packages = with pkgs; [
    gnupg
  ];
}
