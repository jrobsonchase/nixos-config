{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fira-code
    font-awesome
    aegyptus
  ];
}
