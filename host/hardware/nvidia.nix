{
  config,
  lib,
  pkgs,
  modulesPath,
  nixos-hardware,
  ...
}:
with lib;
let
  cfg = config.hardware.graphicsMode;
in
{

  options.hardware.graphicsMode = {
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
      hardware.nvidia = {
        prime = {
          sync.enable = true;
          nvidiaBusId = "${cfg.nvidiaBusId}";
          intelBusId = "${cfg.intelBusId}";
        };

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        modesetting.enable = true;
      };
    })
    (mkIf (cfg.mode == "intel") {
      boot.extraModprobeConfig = ''
        blacklist nouveau
        options nouveau modeset=0
      '';

      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
      boot.blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
      ];
    })
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }
  ]);
}
