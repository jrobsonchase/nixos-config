{ pkgs, config, lib, inputModules, ... }:
{
  imports = [
    ./alacritty.nix
    ./dunst.nix
    ./fonts.nix
    ./waybar.nix
    ./hyprland.nix
    ./polybar.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    systembus-notify
    alacritty
    ibus
    libnotify
    glxinfo
    autorandr
    pavucontrol
    arandr
    xclip
    keepassxc
    xorg.xbacklight
    xorg.xev
    xorg.xmodmap
    scrot
    system-config-printer
    yubioath-flutter
  ];

  home = {
    sessionVariables = {
      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";
    };

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      x11.enable = true;
    };
  };

  programs = {
    alacritty.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.numix-gtk-theme;
      name = "Numix";
    };
  };

  services = {
    syncthing = {
      enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
    network-manager-applet.enable = true;
  };
}
