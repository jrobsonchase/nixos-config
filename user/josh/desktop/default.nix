{ pkgs, config, lib, ... }:
{
  imports = [
    ./alacritty.nix
    ./dunst.nix
    ./fonts.nix
    ./i3.nix
    ./polybar.nix
  ];

  home.packages = with pkgs; [
    lm_sensors
    feh
    alacritty
    picom
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
  ];


  programs = {
    rofi = {
      enable = true;
      theme = "${pkgs.rofi}/share/rofi/themes/Monokai.rasi";
    };
    alacritty.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.numix-gtk-theme;
      name = "Numix";
    };
  };

  xsession = {
    enable = true;
    initExtra = ''
      for i in $(ls $HOME/.xprofile.d); do
        source "$HOME/.xprofile.d/$i"
      done
    '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
    windowManager.i3.enable = true;
  };

  services = {
    wallpaper = {
      enable = true;
      file = ./wallpaper.jpg;
    };
    screen-locker = {
      enable = true;
      xautolock.enable = false;
      inactiveInterval = 5;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
    };
    syncthing = {
      enable = true;
      tray = {
        enable = true;
        command = "syncthingtray --wait";
      };
    };
    dunst.enable = true;
    network-manager-applet.enable = true;
    parcellite.enable = true;
    polybar.enable = true;
  };
}
