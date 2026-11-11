{ self, inputs, ... }:
{
  flake.homeModules.theming =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.homeModules.stylix ];

      # Generate GTK (3/4) and Qt (Kvantum) themes from the same Monokai
      # palette used by noctalia, helix, zellij, etc. Only the toolkit
      # targets are enabled so Stylix leaves the rest of the desktop alone.
      stylix = {
        enable = true;
        autoEnable = false;
        polarity = "dark";

        base16Scheme = "${pkgs.base16-schemes}/share/themes/monokai.yaml";

        # Noctalia uses Monokai's green as its primary accent, while
        # Stylix maps the accent role to base0D (blue) by default.
        override.base0D = "a6e22e";

        # The Qt/Kvantum theme uses base0E for selection highlights.
        # Only override it for Qt so GTK's warning colour stays purple.
        targets.qt.colors.override.base0E = "a6e22e";

        # The Qt target reads these names even when the icon target is off.
        # Keep the default Adwaita icons rather than pulling in a new set.
        icons = {
          dark = "Adwaita";
          light = "Adwaita";
        };

        targets = {
          gtk.enable = true;
          qt = {
            enable = true;
            platform = "qtct";
          };
          firefox = {
            enable = true;
            profileNames = [ "default" ];
            firefoxGnomeTheme.enable = true;
          };
        };

        # Stylix defaults to 12pt; keep the 10pt default these apps had
        # before so only the colours change.
        fonts.sizes.applications = 10;
      };

      # Stylix does not set the GTK colour scheme itself. Without this,
      # libadwaita/GTK4 apps still render with the light scheme.
      gtk.colorScheme = "dark";
    };
}
