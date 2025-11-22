{ pkgs, ... }:
{
  imports = [
    (import ./modules)
  ];

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    homeFlake
    nixosFlake
    homeDiff
    nixosDiff
  ];
}
