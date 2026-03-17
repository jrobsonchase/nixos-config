{
  pkgs,
  config,
  lib,
  inputModules,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./alacritty.nix
    ./dunst.nix
    ./fonts.nix
    ./i3.nix
    ./sway.nix
    ./waybar.nix
    ./polybar.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    pasystray
    paprefs
    feh
    geeqie
    pcmanfm
    systembus-notify
    lm_sensors
    ibus
    libnotify
    mesa-demos
    pavucontrol
    keepassxc
    system-config-printer
    yubioath-flutter
    moonlight-qt
    slack
    discord
    spotify
    evince
    appimage-run
    zoom-us
    wireshark
    nmap
    element-desktop
  ];

  home = {
    sessionVariables = {
      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";
    };

    pointerCursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 32;
      x11.enable = true;
      gtk.enable = true;
      sway.enable = true;
    };
  };

  programs = {
    alacritty.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.yaru-theme;
      name = "Yaru-dark";
    };
    colorScheme = "dark";
  };

  services = {
    flameshot = {
      enable = lib.mkDefault true;
    };
    syncthing = {
      enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
    network-manager-applet.enable = true;
  };

  xsession.profileExtra = ''
    systemctl --user import-environment PATH
  '';
}
