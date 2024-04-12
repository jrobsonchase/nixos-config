{ pkgs, config, lib, inputModules, ... }:
{
  imports = [
    ./hyprland.nix
    ./alacritty.nix
    ./dunst.nix
    ./fonts.nix
    ./i3.nix
    ./polybar.nix
  ];

  home.packages = with pkgs; [
    pasystray
    paprefs

    geeqie
    pcmanfm
    systembus-notify
    lm_sensors
    feh
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
    kitty.enable = true;
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
