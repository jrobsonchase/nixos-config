{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.display.scaling;
in
{
  options.display.scaling = {
    enable = mkEnableOption "Display Scaling";
    factor = mkOption {
      type = with types; number;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      WINIT_X11_SCALE_FACTOR = toString cfg.factor;
      GPUI_X11_SCALE_FACTOR = toString cfg.factor;
    };
    xresources = {
      properties = {
        "Xft.dpi" = cfg.factor * 96;
      };
    };
  };
}
