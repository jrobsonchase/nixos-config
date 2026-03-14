{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      autorandr
      arandr
      xbacklight
      xev
      xmodmap
      xclip
    ];
  };
}
