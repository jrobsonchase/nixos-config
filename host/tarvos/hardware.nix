{ config, lib, pkgs, modulesPath, nixos-hardware, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../../hardware/nvidia.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/2fb8dcee-b889-46db-a0d2-bae27685f71a";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/65B4-4C84";
      fsType = "vfat";
    };

  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/a01c3072-8f8c-418c-8635-43665688c135";
      fsType = "ext4";
    };

  fileSystems."/home/josh" =
    {
      device = "/data/home/josh";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/var/log/ngrok" =
    {
      device = "/data/ngrok-logs";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/var/lib/ngrok" =
    {
      device = "/data/ngrok";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/var/lib/docker" =
    {
      device = "/data/docker";
      fsType = "none";
      options = [ "bind" ];
    };

  fileSystems."/var/lib/rancher/k3s" =
    {
      device = "/data/k3s";
      fsType = "none";
      options = [ "bind" ];
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  boot.initrd.luks.devices = {
    cryptlvm = {
      device = "/dev/disk/by-uuid/6c054e62-0441-46d2-baf1-2d9c1ec8c9a2";
      preLVM = true;
    };
  };

  hardware.customOptimus.enable = true;
  hardware.customOptimus.mode = "intel";
}
