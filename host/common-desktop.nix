# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    ./cachix.nix
  ];

  nix = {
    settings = {
        system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
        "recursive-nix"
      ];
      auto-optimise-store = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes recursive-nix ca-derivations
      keep-outputs = true
      keep-derivations = true
    '';
    gc.automatic = true;
    package = pkgs.nix;
  };

  nixpkgs.config = import ../config.nix;

  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [
    uniemoji
  ];

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";
  # time.timeZone = "US/Central";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
  #   LC_ALL = "C";
  # };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # common X11 settings
  services.xserver = {
    # Configure keymap in X11
    layout = "us";

    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
      };
    };

    displayManager.lightdm.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    git
    stow
    lm_sensors
    acpi
  ];

  programs.dconf.enable = true;

  services.acpid.enable = true;
  services.pcscd.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.pulseaudio = {
    tcp = {
      enable = true;
      anonymousClients.allowAll = true;
    };
    zeroconf = {
      discovery.enable = true;
      publish.enable = true;
    };
  };

  boot.plymouth.enable = true;
  boot.loader.systemd-boot.configurationLimit = 12;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
