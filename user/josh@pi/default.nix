{ ... }:
{
  imports = [
    ../josh
    ../josh/desktop
    ../josh/development
  ];

  wayland.windowManager.hyprland.enable = true;
}
