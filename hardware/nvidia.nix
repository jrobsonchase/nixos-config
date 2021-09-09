{ config, lib, pkgs, modulesPath, nixos-hardware, ... }:
with lib;
let
  cfg = config.hardware.customOptimus;
in
{

  options.hardware.customOptimus = {
    enable = mkEnableOption "optimus management";
    mode = mkOption {
      type = types.str;
      default = "nvidia";
    };
    intelBusId = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
    };
    nvidiaBusId = mkOption {
      type = types.str;
      default = "PCI:1:0:0";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.mode == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia.prime = {
        sync.enable = true;
        nvidiaBusId = "${cfg.nvidiaBusId}";
        intelBusId = "${cfg.intelBusId}";
      };
      hardware.nvidia.modesetting.enable = true;
    })
    (mkIf (cfg.mode == "intel") {
      services.xserver.videoDrivers = [ "intel" ];
      hardware.nvidiaOptimus.disable = true;
    })
  ]);
}
