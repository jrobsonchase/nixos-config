{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    enableScDaemon = true;

    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
  };
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = lib.mkDefault true;
    };
  };
  home.packages = with pkgs; [
    gnupg
  ];
}
