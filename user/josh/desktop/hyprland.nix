{ pkgs, lib, config, ... }:
let
  ifHyprland = lib.mkIf config.wayland.windowManager.hyprland.enable;
in
ifHyprland {
  programs = {
    waybar = {
      enable = true;
    };
  };

  services = {
    dunst.enable = true;
    copyq.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  systemd.user.services.ibus = {
    Unit = {
      Description = "IBus Daemon";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };

    Service = {
      ExecStart = lib.concatStringsSep " " (
        [
          "${pkgs.ibus}/libexec/ibus-ui-gtk3"
          "--enable-wayland-im"
          "--exec-daemon"
          "--daemon-args"
          "--xim --panel disable"
        ]
      );
    };
  };

  wayland.windowManager.hyprland = {
    settings = with pkgs; {
      # Some default env vars.
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor = ",preferred,auto,1";

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Source a file (multi-file configs)
      # source = "~/.config/hypr/myColors.conf";

      # Execute your favorite apps at launch
      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.dex}/bin/dex -ae hyprland"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"
      ];

      # Set programs that you use
      "$terminal" = "${alacritty}/bin/alacritty";
      "$fileManager" = "${pcmanfm}/bin/pcmanfm";
      "$menu" = "${wofi}/bin/wofi --show drun";

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = "no";
        };

        sensitivity = 0;
      };

      general = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        layout = "dwindle";

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;
      };

      debug = {
        # overlay = true;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 6;

        blur = {
          enabled = false;
          size = 3;
          passes = 1;
        };

        drop_shadow = false;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = "yes"; # you probably want this
      };

      master = {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_is_master = true;
      };

      gestures = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        workspace_swipe = "off";
      };

      misc = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more
        force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
        vfr = true;
      };

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.75;
      };

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      windowrulev2 = "suppressevent maximize, class:.*"; # You'll probably like this.

      binds = {
        allow_workspace_cycles = "yes";
      };

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      "$mainMod" = "SUPER";

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod SHIFT, C, killactive,"
        "$mainMod SHIFT, escape, exit,"
        "$mainMod, F, exec, $fileManager"
        "$mainMod SHIFT, space, togglefloating,"
        "$mainMod, D, exec, $menu"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod SHIFT, P, pin"
        "$mainMod, E, togglesplit, # dwindle"
        "$mainMod, W, swapsplit, # dwindle"
        "$mainMod, V, layoutmsg, preselect d, # dwindle"
        "$mainMod, G, layoutmsg, preselect r, # dwindle"

        # Move focus with mainMod + arrow keys
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod, Tab, workspace, previous"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, scratch"
        "$mainMod SHIFT, S, movetoworkspace, special:scratch"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # will switch to a submap called resize
        "$mainMod, R, submap, resize"
      ];

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      source = [
        (writeText "resize-submap" ''

          # will start a submap called "resize"
          submap = resize

          # sets repeatable binds for resizing the active window
          binde=,l,resizeactive,20 0
          binde=,h,resizeactive,-20 0
          binde=,k,resizeactive,0 -20
          binde=,j,resizeactive,0 20

          # use reset to go back to the global submap
          bind=,escape,submap,reset 

          # will reset the submap, meaning end the current one and return to the global one
          submap=reset
        '')
      ];
    };
  };
}
