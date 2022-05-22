{ config, lib, pkgs, modulesPath, inputModules, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/google-compute-image.nix")
  ];

  nix = {
    systemFeatures = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
      "recursive-nix"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes recursive-nix
      keep-outputs = true
      keep-derivations = true
    '';
    gc.automatic = true;
    package = pkgs.nix;
    trustedUsers = [ "@wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

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
        extraGroups = [ "wheel" "docker" "pcap" ];
      };
    };
  };
}