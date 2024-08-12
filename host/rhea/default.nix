{ config, lib, pkgs, modulesPath, inputModules, ... }:

{
  imports =
    [
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
      system-features = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
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

  services.udev.packages = [ pkgs.probe-rs-rules ];
  services.hercules-ci-agent.enable = true;
  services.hercules-ci-agent.settings.concurrentTasks = 4; # Number of jobs to run  
  services.sunshine = {
    enable = true;
    autoStart = true;
    settings = {
      sunshine_name = "rhea-linux";
      global_prep_cmd = builtins.toJSON [{
        do = "${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-2 --mode 1920x1080";
        undo = "${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-2 --mode 3840x1600";
      }];
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
  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "363c67c55aaf5816"
    ];
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      # ngrok-conf = {
      #   path = "/etc/ngrok/ngrok.yml";
      #   format = "binary";
      #   sopsFile = ../../secrets/rhea/ngrok.yml.txt;
      #   mode = "0600";
      #   owner = config.users.users.ngrok.name;
      #   group = config.users.users.ngrok.group;
      #   restartUnits = [ "ngrok.service" ];
      # };
      # hydra-conf = {
      #   path = "/etc/hydra/hydra.conf";
      #   format = "binary";
      #   sopsFile = ../../secrets/rhea/hydra.conf;
      #   owner = config.users.users.hydra.name;
      #   group = config.users.users.hydra.group;
      #   mode = "0660";
      #   restartUnits = [
      #     "hydra-server.service"
      #     "hydra-evaluator.service"
      #     "hydra-init.service"
      #     "hydra-notify.service"
      #     "hydra-queue-runner.service"
      #     "hydra-send-stats.service"
      #   ];
      # };
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
          hostKeys = [ "/etc/ssh/ssh_host_rsa_key" "/etc/ssh/ssh_host_ed25519_key" ];
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
  ];

  services.ntopng.enable = false;

  systemd = {
    oomd.enable = true;
  };

  programs.steam.enable = true;
  programs.wireshark.enable = true;

  services.ngrok = {
    extraConfigFiles = [
      "/etc/ngrok/ngrok.yml"
    ];
    enable = false;
    tunnels = lib.mapAttrs
      (name: label: {
        labels = [ label ];
        addr = "http://localhost:3000";
      })
      {
        hydra = "edge=edghts_2axtHXRyyTK9qERA8kILizR3ilT";
        hydra-webhooks = "edge=edghts_2axtHXRyyTK9qERA8kILizR3ilT";
        hydra-push = "edge=edghts_2axtHXRyyTK9qERA8kILizR3ilT";
      };
  };
  services.hydra = {
    enable = false;
    hydraURL = "https://hydra.robsonchase.com"; # externally visible URL
    notificationSender = "hydra@robsonchase.com"; # e-mail of hydra service
    # you will probably also want, otherwise *everything* will be built from scratch
    useSubstitutes = true;
    extraConfig = ''
      Include /etc/hydra/hydra.conf
      <dynamicruncommand>
        enable = 1
      </dynamicruncommand>
    '';
  };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "524288";
  }];

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
        extraGroups = [ "wheel" "vboxusers" "wireshark" "cups" "docker" "video" "uucp" "pcap" "networkmanager" "scanner" "lp" "dialout" "plugdev" ];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
  };

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
  services.printing.drivers = with pkgs; [ mfcj470dw-cupswrapper mfcj470dwlpr ];

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
        home = { model = "MFC-J470DW"; ip = "192.168.1.31"; };
      };
    };
  };
  system.stateVersion = "24.05";
}
