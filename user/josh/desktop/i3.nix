{
  pkgs,
  lib,
  config,
  ...
}:
let
  mod = "Mod4";
  ifI3 = lib.mkIf config.xsession.windowManager.i3.enable;
in
ifI3 {
  programs = {
    rofi = {
      enable = true;
      theme = "${pkgs.rofi}/share/rofi/themes/Monokai.rasi";
    };
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
    picom = {
      enable = true;
      menuOpacity = 0.9;
      shadow = true;
      fade = true;
      fadeSteps = [
        0.08
        0.08
      ];
      vSync = true;
      backend = "glx";
    };
    dunst.enable = true;
    # parcellite.enable = true;
    polybar.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "gtk"
    ];
  };

  systemd.user.services.ibus = {
    Unit = {
      Description = "IBus Daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = lib.concatStringsSep " " [
        "${pkgs.ibus}/bin/ibus-daemon"
        "-xR"
      ];
    };
  };

  xsession = {
    windowManager.i3 = {
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
          {
            command = "${pkgs.writeShellScriptBin "i3-workspaces.sh" ''
              PATH=${pkgs.i3}/bin:${pkgs.coreutils}/bin:''${PATH}
              for i in $HOME/.i3/workspaces.d/*.json; do
                workspace_name=$(basename -s .json "$i")
                i3-msg "workspace \"$workspace_name\"; append_layout \"$i\""
              done

              for i in $HOME/.i3/workspaces.d/*.sh; do
                $i
              done

              systemctl --user restart polybar
              i3-msg "workspace 1"
            ''}/bin/i3-workspaces.sh";
          }
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

          "${mod}+Escape" = "exec ${pkgs.systemd}/bin/loginctl lock-session";

          "${mod}+t" = "exec ${pkgs.alacritty}/bin/alacritty -t htop -e ${pkgs.htop}/bin/htop";

          # Clear these defaults
          "${mod}+Shift+e" = null;
          "${mod}+Shift+q" = null;

          "${mod}+grave" = "exec ${pkgs.dunst}/bin/dunstctl history-pop";
          "${mod}+Shift+grave" = "exec ${pkgs.dunst}/bin/dunstctl close-all";
          "${mod}+Control+space" = "exec ${pkgs.dunst}/bin/dunstctl close";
          "${mod}+period" = "exec ${pkgs.dunst}/bin/dunstctl action";
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
        for_window [class="zoom"] floating enable
        for_window [class="steam"] floating enable
        for_window [tiling] border pixel 2
      '';
    };
    enable = true;
    initExtra = ''
      for i in $(ls $HOME/.xprofile.d); do
        source "$HOME/.xprofile.d/$i"
      done
    '';
  };
}
