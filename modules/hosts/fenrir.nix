{ self, inputs, ... }:
{
  flake.nixosModules.fenrir =
    # Edit this configuration file to define what should be installed on
    # your system. Help is available in the configuration.nix(5) man page, on
    # https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:

    {
      imports = [
        # Include the results of the hardware scan.
        ./_fenrir/hardware.nix
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        (modulesPath + "/services/hardware/sane_extra_backends/brscan4.nix")
        self.nixosModules.common-desktop
        inputs.sops-nix.nixosModules.sops
        inputs.private.nixosModules.default
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
        # kernelPackages = pkgs.linuxPackages_latest;
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

      services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

      # Hibernate on power button pressed
      services.logind.settings.Login.HandlePowerKey = "hibernate";
      services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";

      # Define time delay for hibernation
      systemd.sleep.settings.Sleep = {
        HibernateDelaySec = "30m";
      };

      networking.hostName = "fenrir"; # Define your hostname.
      networking.useNetworkd = false;
      services.resolved.enable = true;

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "America/Kentucky/Louisville";

      networking.enableIPv6 = false;
      networking.extraHosts = lib.join "\n" [
        "127.0.0.1 registry.local"
      ];

      services.tailscale.enable = true;

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

      hardware.bluetooth.enable = true;
      services.blueman.enable = true;

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

      # Login is handled by Noctalia Greeter (greetd) from common-desktop.

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
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        mfcj470dw-cupswrapper
        mfcj470dwlpr
      ];

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
              "kvm" # /dev/kvm access for claude-desktop cowork's qemu VM
            ];
          };
        };
      };

      programs.nix-ld.enable = true;

      # The claude-desktop bubblewrap sandbox maps only uid 1000, so root-owned
      # store files appear as nobody and ssh rejects the systemd-ssh-proxy Include.
      programs.ssh.systemd-ssh-proxy.enable = false;

      # List packages installed in system profile.
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        helix
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget
        firefox
        xdg-utils
        podman-compose
        qemu_kvm # claude-desktop cowork finds qemu-system-x86_64 via PATH
      ];

      # Claude Desktop's cowork VM probes hardcoded FHS paths for its firmware
      # and virtiofsd; provide them as symlinks rooted by the system closure so
      # automatic GC can't collect the targets out from under them.
      systemd.tmpfiles.rules = [
        "L+ /usr/share/OVMF/OVMF_CODE.fd - - - - ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
        "L+ /usr/share/OVMF/OVMF_VARS.fd - - - - ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"
        "L+ /usr/libexec/virtiofsd - - - - ${pkgs.virtiofsd}/bin/virtiofsd"
      ];

      # Fix uv python ssl.SSLCertVerificationError
      environment.etc.certfile = {
        source = "/etc/ssl/certs/ca-bundle.crt";
        target = "ssl/cert.pem";
      };

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

    };

  flake.nixosConfigurations.fenrir = self.lib.nixosSystem self.nixosModules.fenrir;

  flake.homeModules.josh-fenrir =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.homeModules.josh-sway-full
        self.homeModules.gitsign
        self.homeModules.opencode
        self.homeModules.claude
        self.homeModules.pi
      ];

      home.packages = with pkgs; [
        gh
        (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
        obsidian
        (symlinkJoin {
          name = "claude-desktop-with-chrome";
          paths = [ claude-desktop ];
          nativeBuildInputs = [ makeWrapper ];
          postBuild = ''
            for bin in "$out"/bin/*; do
              wrapProgram "$bin" --prefix PATH : ${lib.makeBinPath [ google-chrome ]}
            done
          '';
        })
      ];
    };

  flake.homeConfigurations."josh@fenrir" =
    self.lib.homeConfiguration "josh" "x86_64-linux"
      self.homeModules.josh-fenrir;
}
