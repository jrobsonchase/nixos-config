{ self, ... }:
{
  flake.homeModules.desktop =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = [
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

      gtk = {
        enable = true;
        theme = {
          package = pkgs.yaru-remix-theme;
          name = "Yaru-remix-dark";
        };
        gtk4.theme = config.gtk.theme;
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
    };
}
