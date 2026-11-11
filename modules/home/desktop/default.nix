{ self, ... }:
{
  flake.homeModules.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.desktop.extraPackages.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install the extra desktop applications that are not available on every platform.";
      };

      imports = [
        self.homeModules.theming
        self.homeModules.hyprland
        self.homeModules.alacritty
        self.homeModules.dunst
        self.homeModules.fonts
        self.homeModules.i3
        self.homeModules.sway
        self.homeModules.noctalia
        self.homeModules.waybar
        self.homeModules.polybar
        self.homeModules.firefox
      ];

      config = {
        home.packages = lib.optionals config.desktop.extraPackages.enable (
          with pkgs;
          [
            pasystray
            paprefs
            feh
            geeqie
            pcmanfm
            systembus-notify
            lm_sensors
            ibus
            libnotify
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
          ]
        );

        home = {
          sessionVariables = {
            GTK_IM_MODULE = "ibus";
            XMODIFIERS = "@im=ibus";
            QT_IM_MODULE = "ibus";
          };

          pointerCursor = {
            enable = true;
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
      };
    };
}
