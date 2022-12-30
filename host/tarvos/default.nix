{ config, lib, pkgs, modulesPath, inputModules, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware.nix
      inputModules.private.defaultModule
      (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
      ../common-desktop.nix
    ];

  nix.settings.trusted-users = [ "josh" ];

  boot.cleanTmpDir = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For emulated compilation
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "i686-linux"
  ];

  networking.hostName = "tarvos"; # Define your hostname.
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
    fuse
    innernet
    ntfsprogs
  ];

  # services.bind.enable = true;
  services.bind.forwarders = [ "1.1.1.1" ];

  services.ntopng.enable = true;

  systemd = {
    packages = [ pkgs.innernet ];
    targets = {
      innernet-interfaces = {
        description = "All innernet interfaces";
        wantedBy = [ "multi-user.target" ];
        wants = (map (i: "innernet@${i}.service") [ "rcnet" ]);
      };
    };
    oomd.enable = true;
  };

  programs.steam.enable = true;
  programs.wireshark.enable = true;

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "524288";
  }];

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
        extraGroups = [ "wheel" "vboxusers" "wireshark" "cups" "docker" "video" "uucp" "pcap" "networkmanager" "scanner" "lp" ];
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager = {
      defaultSession = "none+i3";

      autoLogin = {
        enable = true;
        user = "josh";
      };
    };
  };

  # Enable sound.
  sound.enable = true;

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
    extraOptions = "--log-opt max-size=10m --dns 8.8.8.8 --dns 8.8.4.4";
  };

  # networking.resolvconf.useLocalResolver = false;
  # networking.resolvconf.extraConfig = ''
  #   name_servers='127.0.0.1 8.8.8.8'
  # '';

  services.hydra = {
    enable = false;
    hydraURL = "http://localhost:3000"; # externally visible URL
    notificationSender = "hydra@localhost"; # e-mail of hydra service
    # a standalone hydra will require you to unset the buildMachinesFiles list to avoid using a nonexistant /etc/nix/machines
    buildMachinesFiles = [ ];
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
  };

  services.murmur = {
    enable = false;
    extraConfig = ''
      grpc="127.0.0.1:50051"
    '';
  };

  services.autorandr = {
    enable = true;
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ mfcj470dw-cupswrapper mfcj470dwlpr ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns = true;

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = { model = "MFC-J470DW"; ip = "192.168.1.29"; };
      };
    };
  };
}
