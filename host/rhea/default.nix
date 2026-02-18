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
    ./hardware.nix
    inputModules.private.default
    (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
    ../common-desktop.nix
    inputModules.ngrok.ngrok
    inputModules.sops-nix.sops
  ];

  time.hardwareClockInLocalTime = true;
  nix = {
    gc.automatic = true;
    settings = {
      system-features = [
        "kvm"
        "nixos-test"
        "big-parallel"
        "benchmark"
      ];
      trusted-users = [ "josh" ];
      max-jobs = 4;
      cores = 16;
      allowed-uris = [
        "git+ssh://"
        "ssh://"
        "git+https://"
        "https://"
        "github:"
        "gitlab:"
      ];
    };
    distributedBuilds = true;
    # optional, useful when the builder has a faster internet connection than yours
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  programs.nix-ld.enable = true;

  services.smartd.enable = true;
  services.udev.packages = [ pkgs.probe-rs-rules ];
  # services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 4; # Number of jobs to run
  services.sunshine = {
    enable = false;
    autoStart = true;
    settings = {
      sunshine_name = "rhea-linux";
      global_prep_cmd = builtins.toJSON [
        {
          do = "${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-2 --mode 1920x1080";
          undo = "${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-2 --mode 3840x1600";
        }
      ];
    };
    applications = {
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Steam";
          detached = [
            "${pkgs.steam}/bin/steam steam://open/bigpicture"
          ];
          image-path = "steam.png";
        }
      ];
    };
  };
  services.tailscale.enable = true;

  # Local LLM service
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      wireguard-key = {
        path = "/etc/wireguard/private.key";
        format = "binary";
        sopsFile = ../../secrets/rhea/wireguard.key;
        restartUnits = [ "wireguard-wg0.service" ];
      };
    };
  };

  programs.ssh.extraConfig = ''
    ServerAliveInterval 60
  '';

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;

    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "r8169" ];
      network = {
        enable = true;
        flushBeforeStage2 = true;
        udhcpc.enable = true;
        ssh = {
          enable = true;
          port = 22;
          shell = "/bin/cryptsetup-askpass";
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKhzvYI7/F8OzLyrgx3p3pLmL+yQ0Vc9qQEwftW8mKm6 cardno:17_615_916"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICipOrxTV56dTXQYZto1pf67VDHsZGRgXMyN4wCpmvql u0_a371@localhost"
          ];
          hostKeys = [
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_ed25519_key"
          ];
        };
      };
    };
  };

  networking.hostName = "rhea"; # Define your hostname.
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [
      3000
      5900
      27036
      27037
    ];
    allowedUDPPorts = [
      27031
      27036
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;
  # Enable wake on lan
  networking.interfaces.enp13s0.wakeOnLan.enable = true;

  environment.systemPackages = with pkgs; [
    fuse
    ntfsprogs
    gnome-network-displays
    smartmontools
  ];

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
      plugdev = { };
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
          "plugdev"
        ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      StreamLocalBindUnlink = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
  };

  security.pam.services.i3lock.enable = true;

  services.displayManager = {
    # gdm.enable = true;
    # lightdm.enable = lib.mkForce false;
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

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    mfcj470dw-cupswrapper
    mfcj470dwlpr
  ];

  services.avahi.enable = true;
  # Important to resolve .local domains of printers, otherwise you get an error
  # like  "Impossible to connect to XXX.local: Name or service not known"
  services.avahi.nssmdns4 = true;

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "gtk";
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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
  system.stateVersion = "24.05";
}
