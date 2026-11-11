{ self, ... }:
{
  flake.homeModules.noctalia =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    with lib;
    let
      cfg = config.noctalia;

      # Version 1 palette format (m-prefixed keys). Noctalia's v2 loader
      # leaves some derived text roles black, so stick with the format used
      # by the community palettes.
      monokai = {
        dark = {
          mPrimary = "#a6e22e";
          mOnPrimary = "#272822";
          mSecondary = "#66d9ef";
          mOnSecondary = "#272822";
          mTertiary = "#f92672";
          mOnTertiary = "#272822";
          mError = "#f92672";
          mOnError = "#272822";
          mSurface = "#272822";
          mOnSurface = "#f8f8f2";
          mSurfaceVariant = "#3e3d32";
          mOnSurfaceVariant = "#a59f85";
          mOutline = "#75715e";
          mShadow = "#272822";
          mHover = "#3a3a32";
          mOnHover = "#f8f8f2";
          terminal = {
            foreground = "#f8f8f2";
            background = "#272822";
            cursor = "#f8f8f2";
            cursorText = "#272822";
            selectionFg = "#272822";
            selectionBg = "#f8f8f2";
            normal = {
              black = "#272822";
              red = "#f92672";
              green = "#a6e22e";
              yellow = "#f4bf75";
              blue = "#66d9ef";
              magenta = "#ae81ff";
              cyan = "#a1efe4";
              white = "#f8f8f2";
            };
            bright = {
              black = "#75715e";
              red = "#f92672";
              green = "#a6e22e";
              yellow = "#f4bf75";
              blue = "#66d9ef";
              magenta = "#ae81ff";
              cyan = "#a1efe4";
              white = "#f9f8f5";
            };
          };
        };
      };
    in
    {
      options.noctalia.enable = mkEnableOption "Noctalia desktop shell";

      config = mkIf cfg.enable {
        home.packages = [ pkgs.noctalia ];

        # Noctalia reads every *.toml in ~/.config/noctalia/. The GUI saves
        # overrides to ~/.local/state/noctalia/settings.toml, so this stays
        # writable even though the config directory is a read-only store link.
        xdg.configFile."noctalia/config.toml".source =
          (pkgs.formats.toml { }).generate "noctalia-config.toml"
            {
              shell = {
                setup_wizard_enabled = false;
                polkit_agent = true;
                font_family = "DejaVu Sans";
                time_format = "{:%H:%M}";
                date_format = "%A, %B %-d";
                greeter_sync.auto_sync = true;
              };

              theme = {
                mode = "dark";
                shell_mode = "follow";
                source = "custom";
                custom_palette = "Monokai";
                sync_color_scheme = true;
              };

              wallpaper = {
                enabled = true;
                fill_mode = "crop";
                transition_on_startup = false;
                default.path = "${./wallpaper.jpg}";
              };

              bar.default = {
                position = "top";
                enabled = true;
                reserve_space = true;
                thickness = 32;
                radius = 0;
                concave_edge_corners = false;
                margin_ends = 0;
                padding = 14;
                widget_spacing = 6;
                start = [
                  "launcher"
                  "workspaces"
                ];
                center = [ "clock" ];
                end = [
                  "tray"
                  "notifications"
                  "volume"
                  "network"
                  "bluetooth"
                  "battery"
                  "control-center"
                ];
                dead_zone.actions = {
                  left = "panel-toggle launcher";
                  right = "panel-toggle control-center";
                };
              };

              # Noctalia owns org.freedesktop.Notifications; dunst is disabled
              # by the sway module while this is enabled.
              notification.enable_daemon = true;
            };

        xdg.configFile."noctalia/palettes/Monokai.json".source =
          (pkgs.formats.json { }).generate "Monokai.json"
            monokai;
      };
    };
}
