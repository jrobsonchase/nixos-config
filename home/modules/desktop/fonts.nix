{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fira-code
    nerd-fonts.symbols-only
    font-awesome
    aegyptus
    dejavu_fonts
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-emoji-blob-bin
  ];
  fonts.fontconfig.enable = true;
}
