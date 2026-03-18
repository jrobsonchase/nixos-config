{ config, lib, pkgs, modulesPath, inputModules, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      inputModules.nixos-hardware.framework-amd-ai-300-series
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.fstrim.enable = true;

  boot.initrd.luks.devices = {
    cryptlvm = {
      device = "/dev/disk/by-uuid/7f8447d2-62fe-4c71-9864-8828660c0734";
      preLVM = true;
    };
  };

  fileSystems."/" =
    { device = "/dev/mapper/VG0-root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6589-57D5";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [
    {
      device = "/dev/mapper/VG0-swap";
      priority = 1;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
