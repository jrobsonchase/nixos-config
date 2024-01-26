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

  networking.hostName = "hyperion";

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
        extraGroups = [ "wheel" "docker" "pcap" "wireshark" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxNLx/DUgZc3rySe8XV+9KoMQ3ELBUqp29Uo4wIzD4M7wMPO0VkRykg6zAwB1F3eY4Rfi9/ASA3L5QxYvRO/QWVF/yKHnrQRNLQwtXd2xufjMlbSVtjuAC/x4r7gfw30X38MuA3Qb3GvGZiOuUoSyTafnw+fX1coCPGmMTU5DP8SBx3GsfmNUkG6Ezf2iofjrrM1W3vH1OgtAk2Mju0WpUuc4DAvT+/APhKEpAcXkubsjqhFXnDN5BlYkFUaNGltcx0PypSVycWueIxs8NGgudgVL7U8OXSrAy41x50pmBz3UQ+SBgYXN38e8FAMHYPw0DjCVwvIfFv6FXC4XVT+1Zb+8+cJGdoeRXOJOieN0cHO4PCx3YOMARjr4Gzc5EiEPNyMSqAnn7Th1k2aJ8yUMrUjDZVuAl6rSEpE/jocWWnnmfcCcmyBlMedIt4L9OkL3sRBO5ey+Hldj6w+pjmrLlmoCzJ6ljPGigykfCxtGzDFt9vQFKYeno1FXuBktcmvwZ4ctoWrG42q8p5gz7i+MAj94PeJf81FHb+UXWUOZveLOwr+dQ+7hf2VRv6pSA/hDK/EfVb/H9gnm4p/T5JzfdjzRwyavf+L/1oMB/OtKKdZ8lHCFGEA5XKSdQMjxgtKB/Pin6K8wDWG+lERcTw9WMevPCZ076mhYXXTQCzSS27w== cardno:9 729 742"
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF9Y4w2UonW6nMsA2Km0XGUcfBC7PQ63uzew7SaLwoEs3AB5Oflndpl5JWQf9RN+nEqznfzbBZp6p7RrDf6EOsI= u0_a423@localhost"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgLR2/8ze7R8iMxDRU6sjI6pBtBH7A/y1EEF5cYhQA5ukUkJ7u+Q4zt/amNwoaziOQ5IkY1GiB83sUNPXt6ca5xBX4qYN0POPB9WZ/4bpDrs7WHto0cvL8HTo0Wwq9uXoWUfr3mwn7aHSQxFVeeY6gaFGAq4794tH4CJwcjaEvBsRwdR3x1H2glRRmmzDHre5KbS/KWoCenBsJ0x1UDxTXSmIK3lmm1avwtYBDYTzbJhOQc7CADiItFysf8vj5SBUsbOIFKbHw2DB1Iv1DlWSu/dizh63NrOOeqP4L9hiJqv+HEmn8OG6nKUmjDZ2M6tN8l/95rM3r6bKE1E2wSjTfYUF+n/sUwcDiNdnHIchZBs6KrPZYH+Tb0d0n64Ze7Go5kzwh8un2ReCF9ghao0Wk5hTNh0CzYFuA2BvrzutPYxgmpGnSjhm+R9WlvBVM8ntbgDRiNmNjJmu5QupSjYS3FCE98a3ILA9NU4LO4/bQaWYFbAfPwCokia5loPFeUps= nix-on-droid@localhost"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dconf
    innernet
    mudrs-milk
    ripgrep
    tcpdump
    screen
    syncthing
    mosh
    vim
    deno
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-vsliveshare.vsliveshare
        denoland.vscode-deno
      ];
    })
  ];

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      power-theme
    ];
  };

  services.openssh.settings.X11Forwarding = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  systemd = {
    packages = [ pkgs.innernet ];
    targets = {
      innernet-interfaces = {
        description = "All innernet servers";
        wantedBy = [ "multi-user.target" ];
        wants = (map (i: "innernet-server@${i}.service") [ "rcnet" ]);
      };
    };
  };

  system.stateVersion = "22.05";
}
