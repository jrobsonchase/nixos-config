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
    profiles.default.settings = {
      "browser.ctrlTab.sortByRecentlyUsed" = true;
    };
  };
}
