# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  modulesPath,
  flakeModulesPath,
  flakeModules,
  inputModules,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
    flakeModules.nixpkgs
    (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
    (flakeModulesPath + "/common-desktop.nix")
    inputModules.sops-nix.sops
    inputModules.private.default
  ];

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
    buildMachines = [
      {
        hostName = "rhea";
        protocol = "ssh-ng";
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
    # optional, useful when the builder has a faster internet connection than yours
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  boot = {
    tmp.cleanOnBoot = true;
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = true;
    };
  };

  networking.hostName = "fenrir"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";

  networking.enableIPv6 = false;
  networking.extraHosts = lib.join "\n" [
    "127.0.0.1 registry.local"
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Secrets
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # disable the X11 windowing system.
  services.xserver = {
    enable = false;
    windowManager.i3.enable = false;
    displayManager.lightdm.enable = false;
  };

  # programs.regreet.enable = true;

  systemd = {
    oomd.enable = true;
  };

  security.pam.services.swaylock.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  programs.nix-ld.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    helix
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    xdg-utils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    allowedTCPPorts = [
      22000
    ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
