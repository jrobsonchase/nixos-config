{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.keepassxc
    ];
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.default.settings = {
      "browser.ctrlTab.sortByRecentlyUsed" = true;
    };
  };
}
