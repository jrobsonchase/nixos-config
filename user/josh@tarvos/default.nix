{ pkgs, lib, ... }:
{
  imports = [
    ../josh/i3-full.nix
  ];

  programs.alacritty.settings.font.size = lib.mkForce 14;
}
