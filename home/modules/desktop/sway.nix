{
  pkgs,
  lib,
  config,
  ...
}:
let
  mod = "Mod4";
  ifSway = lib.mkIf config.wayland.windowManager.sway.enable;
  rofi-nix = pkgs.writeShellScript "nix_run.sh" ''
    #!${pkgs.bash}/bin/bash

    if [ x"$@" != x"" ]; then
        coproc ( nix run pkgs#$@ >/dev/null 2>&1 )
    fi

    exit 0
  '';
in
{
  imports = [
    ./waybar.nix
  ];
  config = ifSway {
    home.packages = with pkgs; [
      wl-clipboard
      swaylock
    ];
    programs.waybar.enable = true;
    programs = {
      rofi = {
        enable = true;
        theme = "${pkgs.rofi}/share/rofi/themes/Monokai.rasi";
      };
    };
    services.flameshot.enable = false;
    services.dunst.enable = true;
    services.screen-locker = {
      enable = true;
      xautolock.enable = false;
      inactiveInterval = 5;
      lockCmd = "${pkgs.swaylock}/bin/swaylock -c 000000";
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config.common.default = [
        "wlr"
      ];
    };

    wayland.windowManager.sway = {
      wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
      config = rec {
        modifier = "${mod}";
        terminal = "${pkgs.alacritty}/bin/alacritty";
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
          { command = "systemctl --user import-environment PATH XDG_SESSION_ID"; }
        ];
        output = {
          "DP-3" = {
            scale = "1.0";
            bg = "${./wallpaper.jpg} fill";
            pos = "0 0";
          };
          "eDP-1" = {
            scale = "1.25";
            bg = "${./wallpaper.jpg} fill";
            pos = "3840 588";
          };
        };
        menu = "--no-startup-id ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu='${pkgs.rofi}/bin/rofi -i -dmenu'";
        workspaceAutoBackAndForth = true;
        input = {
          "type:touchpad" = {
            dwt = "enabled";
            dwtp = "enabled";
            tap = "enabled";
            tap_button_map = "lrm";
            natural_scroll = "enabled";
          };
        };

        keybindings = lib.mkOptionDefault {
          "${mod}+Tab" = "workspace Tab";
          "${mod}+Shift+Tab" = "move container to workspace Tab";
          "${mod}+s" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -show window ";
          "${mod}+n" = "exec --no-startup-id ${pkgs.rofi}/bin/rofi -modes \"nix:${rofi-nix}\" -show nix";
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
          "${mod}+Shift+Escape" = "exec swaymsg exit";
          "${mod}+Shift+p" = "sticky toggle";
          "${mod}+p" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot savecopy anything";

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
        titlebar_padding 5 1
        for_window [title="htop"] floating enable
        for_window [class="zoom"] floating enable
        for_window [class="steam"] floating enable
        for_window [tiling] border pixel 2
      '';
    };
  };
}
