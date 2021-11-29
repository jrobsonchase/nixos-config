{ pkgs, ... }:
{
  imports = [
    (import ./modules)
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = [ pkgs.nixUnstable ];

  nixpkgs.config = import ../config.nix;
}
