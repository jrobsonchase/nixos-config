{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.services.wallpaper;
in
{
  options.services.wallpaper = {
    enable = mkEnableOption "Desktop wallpaper";
    file = mkOption {
      type = with types; either str path;
    };
    method = mkOption {
      default = "scale";
      type =
        with types;
        either bool (enum [
          "center"
          "fill"
          "max"
          "scale"
          "tile"
        ]);
    };
    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    home.file.".fehbg".text =
      let
        wallpaperFile = pkgs.copyPathToStore cfg.file;
      in
      ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.feh}/bin/feh --no-fehbg --bg-${cfg.method} ${wallpaperFile} ${concatStringsSep " " cfg.extraOptions}
      '';

    systemd.user.services.fehbg = {
      Unit = {
        Description = "Set desktop wallpaper with fehbg";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = concatStringsSep " " ([
          "${pkgs.bash}/bin/bash"
          "${config.home.homeDirectory}/.fehbg"
        ]);
        Type = "oneshot";
        RemainAfterExit = "yes";
      };
    };
  };
}
