{ pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  boot.loader.grub.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  boot = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.crossRpi5.linux_rpi5;
    kernelParams =
      [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" "cma=128M" ];
  };

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  # user account.
  users.users.josh = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhzvYI7/F8OzLyrgx3p3pLmL+yQ0Vc9qQEwftW8mKm6 cardno:17_615_916"
    ];
  };

  services.openssh = {
    enable = true;
  };

  sdImage.compressImage = false;
  system.stateVersion = "24.05";
}
