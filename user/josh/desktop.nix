{ pkgs, config, lib, ... }:
{
  home.packages = with pkgs; [
    feh
    alacritty
    picom
    ibus
    polybarFull
    libnotify
    glxinfo
    autorandr
    pavucontrol
    arandr
    xclip
    keepassxc
    xorg.xbacklight
    scrot
    dunst
  ];

  gtk = {
    enable = true;
    theme = {
      package = pkgs.numix-gtk-theme;
      name = "Numix";
    };
  };

  services.parcellite = {
    enable = true;
  };

  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
  };

  xsession.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
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
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
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

  xsession.enable = true;
  xsession.initExtra = ''
    for i in $(ls $HOME/.xprofile.d); do
      source "$HOME/.xprofile.d/$i"
    done
  '';

  xsession.windowManager.i3 =
    let
      mod = "Mod4";
    in
    {
      enable = true;
      config = {
        modifier = mod;
        fonts = {
          names = [ "DejaVu Sans Mono" ];
          size = 10.0;
        };
        window = {
          titlebar = false;
          border = 2;
        };
        floating = {
          border = 2;
        };
        startup = [
          { command = "~/.i3/workspaces.sh"; }
          { command = "${pkgs.dex}/bin/dex -ae i3"; }
          { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"; }
        ];
        terminal = "${pkgs.alacritty}/bin/alacritty";
        menu = "--no-startup-id i3-dmenu-desktop --dmenu='${pkgs.rofi}/bin/rofi -i -dmenu'";
        workspaceAutoBackAndForth = true;
        keybindings = lib.mkOptionDefault {
          "${mod}+Tab" = "workspace Tab";
          "${mod}+Shift+Tab" = "move container to workspace Tab";
          "${mod}+s" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show window ";
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";
          "${mod}+Shift+Left" = "move workspace to output left";
          "${mod}+Shift+Down" = "move workspace to output down";
          "${mod}+Shift+Up" = "move workspace to output up";
          "${mod}+Shift+Right" = "move workspace to output right";
          "${mod}+g" = "split h";
          "${mod}+v" = "split v";
          "${mod}+F11" = "fullscreen";
          "${mod}+z" = "focus child";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+Escape" = "exec i3-msg exit";
          "${mod}+Shift+p" = "sticky toggle";

          "${mod}+Shift+c" = "kill";

          "${mod}+Escape" = "exec loginctl lock-session";

          "${mod}+t" = "exec alacritty -t htop -e ${pkgs.htop}/bin/htop";

          # Clear these defaults
          "${mod}+Shift+e" = null;
          "${mod}+Shift+q" = null;
        };
        modes.resize = {
          "h" = "resize shrink width 5 px or 5 ppt";
          "j" = "resize grow height 5 px or 5 ppt";
          "k" = "resize shrink height 5 px or 5 ppt";
          "l" = "resize grow width 5 px or 5 ppt";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
        bars = [ ];
      };
      extraConfig = ''
        for_window [title="htop"] floating enable
      '';
    };
}
