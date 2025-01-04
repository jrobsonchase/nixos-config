{ config, lib, pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;

    pinentryPackage =
      if pkgs.hostPlatform.isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-qt;
  };
  home.packages = with pkgs; [
    gnupg
  ];
}
