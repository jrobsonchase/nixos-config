{
  config,
  lib,
  pkgs,
  modulesPath,
  inputModules,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware.nix
    inputModules.private.default
    (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
    ../common-desktop.nix
  ];

  nix.settings.trusted-users = [ "josh" ];
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "rhea";
      system = "x86_64-linux";
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];

  boot = {
    tmp.cleanOnBoot = true;

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "tarvos"; # Define your hostname.
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wpa_supplicant_gui
    fuse
    ntfsprogs
    gnome-network-displays
  ];

  # services.bind.enable = true;
  services.bind.forwarders = [ "1.1.1.1" ];

  services.ntopng.enable = false;

  systemd = {
    oomd.enable = true;
  };

  programs.steam.enable = true;
  programs.wireshark.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
  ];

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
        extraGroups = [
          "wheel"
          "vboxusers"
          "wireshark"
          "cups"
          "docker"
          "video"
          "uucp"
          "pcap"
          "networkmanager"
          "scanner"
          "lp"
          "dialout"
        ];
      };
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
  };

  services.displayManager = {
    defaultSession = "none+i3";

    autoLogin = {
      enable = true;
      user = "josh";
    };
  };

  virtualisation.docker = {
    enable = true;
    logDriver = "json-file";
    extraOptions = "--log-opt max-size=10m --dns 8.8.8.8 --dns 8.8.4.4";
  };

  services.autorandr = {
    enable = true;
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    mfcj470dw-cupswrapper
    mfcj470dwlpr
  ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns4 = true;

  services.fwupd.enable = true;

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "gtk";
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  networking.firewall.enable = false;

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "MFC-J470DW";
          ip = "192.168.1.31";
        };
      };
    };
  };

  system.stateVersion = "21.11";
}
