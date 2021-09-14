{ config, lib, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles.default.settings = {
      "browser.ctrlTab.sortByRecentlyUsed" = true;
    };
  };
}
