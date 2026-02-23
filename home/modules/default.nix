{ pkgs, ... }:
{
  imports = [
    ./wallpaper.nix
    ./bash.nix
  ];

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    home-flake
    nixos-flake
    home-diff
    nixos-diff
  ];
}
