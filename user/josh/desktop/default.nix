{ pkgs, config, lib, ... }:
{
  imports = [
    ./fonts.nix
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

  services.network-manager-applet.enable = true;

  programs.alacritty = {
    enable = true;
    settings = import ./alacritty.nix { inherit pkgs; };
  };

  services.polybar = {
    enable = true;
    config = ./polybar.conf;
    package = pkgs.polybarFull;
    script = ''
      PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:${pkgs.iproute2}/bin:${pkgs.procps}/bin:''${PATH}

      set -x

      MONITORS=$(polybar -m | sed 's/:.*//')

      INTERFACES=$(ip link | grep -P '\d: en' | cut -d : -f 2 | tr -d ' ')
      ETH_CTR=1
      for iface in $INTERFACES; do
        eval "export POLYBAR_ETH''${ETH_CTR}=$iface"
        let ETH_CTR+=1
      done

      export POLYBAR_WLAN=$(ip link | grep -P '\d: wl' | cut -d : -f 2 | tr -d ' ')

      for monitor in $MONITORS
      do
        MONITOR=$monitor polybar -r i3 &
        sleep 0.5
      done
    '';
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.numix-gtk-theme;
      name = "Numix";
    };
  };

  services.wallpaper = {
    enable = true;
    file = ./wallpaper.jpg;
  };

  services.parcellite = {
    enable = true;
  };

  services.screen-locker = {
    enable = true;
    xautolock.enable = false;
    inactiveInterval = 5;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
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
    windowManager.i3 = import ./i3.nix { inherit pkgs lib; };
  };

  services.syncthing = {
    enable = true;
    tray = {
      enable = true;
      command = "syncthingtray --wait";
    };
  };

  programs.rofi = {
    enable = true;
    theme = "${pkgs.rofi}/share/rofi/themes/Monokai.rasi";
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "Monospace-10";
        format = "%s\n%b";
        sort = true;
        indicate_hidden = true;
        bounce_freq = 0;
        show_age_threshold = 60;
        word_wrap = true;
        ignore_newline = false;
        geometry = "0x5-30+20";
        transparency = 15;
        idle_threshold = 120;
        monitor = 0;
        follow = "keyboard";
        sticky_history = true;
        line_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        separator_color = "frame";
        startup_notification = false;
        browser = "firefox -new-tab";
        frame_width = 3;
        frame_color = "#aaaaaa";
        timeout = 10;
      };
      urgency_low = {
        background = "#222222";
        foreground = "#ffffff";
      };
      urgency_normal = {
        background = "#285577";
        foreground = "#ffffff";
      };
      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
      };
    };
  };

}
