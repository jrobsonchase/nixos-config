{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fira-code
    font-awesome
    aegyptus
    dejavu_fonts
  ];
  fonts.fontconfig.enable = true;
}
