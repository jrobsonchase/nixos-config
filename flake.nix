{
  inputs = {
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    # Upstream package flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    # Bonus modules for hardware setup
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust overlay
    fenix = {
      url = "github:nix-community/fenix";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    };

    # Individual applications
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rpi5 = {
      url = "gitlab:jrobsonchase/nix-rpi5/flake-improvements";
    };

    zed = {
      url = "github:jrobsonchase/zed/devel";
    };
  };

  outputs =
    { private, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    extra-substituters = [
      "https://jrobsonchase.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "jrobsonchase.cachix.org-1:YOmfoK1M7kCwfC/RirSXLck9bplLNFh6U/syn1q/H84="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
