{ config, lib, pkgs, modulesPath, inputModules, ... }:

{
  imports =
    [
      ./hardware.nix
      inputModules.private.default
      (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
      ../common-desktop.nix
      inputModules.ngrok.ngrok
    ];

  time.hardwareClockInLocalTime = true;
  nix = {
    settings = {
      system-features = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      trusted-users = [ "josh" ];
      max-jobs = 4;
      cores = 16;
    };
    # buildMachines = [{
    #   hostName = "aws-dev";
    #   sshUser = "josh";
    #   system = "x86_64-linux";
    #   maxJobs = 8;
    #   speedFactor = 2;
    #   supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    #   mandatoryFeatures = [ ];
    # }];
    distributedBuilds = true;
    # optional, useful when the builder has a faster internet connection than yours
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  programs.ssh.extraConfig = ''
    ServerAliveInterval 60
  '';

  boot = {
    tmp.cleanOnBoot = true;

    binfmt.emulatedSystems = [
      "aarch64-linux"
      "x86_64-windows"
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
          authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDChYWvcv6sB8gOcJttQhCQkrMesstPQ6I4Lge0WISRdNFHiTwoklBT5DKJwbiI4Q/ldZu+GTNIBYn1fjmwDnq6UoS5jlpk7GZUhEIGSCmL4s5VQ+4Bhhn1Rias7PHgwQEaOXsIUGcCD0boudFjY3lMnI4Tj2y5+JZNHLs+xHFVAtoWxKjE4D+CJtChoB/HbVIsecdjTyUKcDh1wHzB+sr0mpJMPtRkB62u7w0FxR8IMy1p1iXByzu4VeaUsNOa3z2TFrY2FTJwvYG6vd4gWUjRYsrVGAorht07S2WijiqqhbsxabJjL10QIQQ7zFI4TO4pEj/IexFWRoV+v0lG21d05fw4PMD67z0FwgoD+ZaJN3m59bIN5+FW84Tw2S/hhrs3T4stoatKtXOgWk9+OzkNR0Nn7cPTx2jkhYmoR0WNimyDJTPq5i/abCKCXkPkN0yI/VripAL7Xa1GJNtrts+MXMmgbTpHewH0KewH5bYULwnyOFXH6HsbsXgcfwce3/ZS2lQzT5hVzrUjCxMKbrOrpPuMK4+6Q3rQCAuAxl8mhW6JPXfZ78q3350v6Xp2XpJq4Ui2yJnRntI+IR3r5ynpcql3D6HfLKGIkgNfEI3SVrulk0lpzq35R1tkReFuWniLVUp7vegsCdyW39mNMibgzac+2fGTItiysAi1Q+aLOQ== cardno:9_729_742" ];
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
    enable = true;
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
    enable = true;
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
    displayManager = {
      # gdm.enable = true;
      # lightdm.enable = lib.mkForce false;
      defaultSession = "none+i3";

      autoLogin = {
        enable = true;
        user = "josh";
      };
    };
    xkbVariant = "";
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

  # hardware.bluetooth.enable = true;
  # services.blueman.enable = true;

  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = { model = "MFC-J470DW"; ip = "192.168.1.29"; };
      };
    };
  };
  system.stateVersion = "24.05";
}
