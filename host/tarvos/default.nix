{ config, lib, pkgs, modulesPath, inputModules, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware.nix
      inputModules.private.ngrok
      inputModules.private.networks
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tarvos"; # Define your hostname.
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  networking.wireless.extraConfig = ''
    p2p_disabled=1
  '';

  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp82s0.useDHCP = true;

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
  ];

  services.ngrok-devenv.enable = true;
  services.ngrok-devenv.unifiedCgroups = true;
  services.bind = { enable = true; forwarders = [ "1.1.1.1" ]; };

  users = {
    groups = {
      josh = {
        gid = 1000;
      };
    };
    users = {
      josh = {
        isNormalUser = true;
        group = "josh";
        uid = 1000;
        extraGroups = [ "wheel" "vboxusers" "wireshark" "cups" "docker" "video" "uucp" "pcap" ];
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
    extraOptions = "--log-opt max-size=10m --dns 8.8.8.8 --dns 8.8.4.4";
  };
}
