{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private.url = "path:./private";
  };
  outputs = { self, nixpkgs, nixos-hardware, private, home-manager, ... }:
    let
      inherit (builtins) getAttr attrNames listToAttrs concatMap;
      inherit (nixpkgs.lib) genAttrs nixosSystem;

      hosts = {
        tarvos = {
          system = "x86_64-linux";
        };
      };

      users = [ "josh" ];

      genUsers = f: (listToAttrs (concatMap
        (user: (map
          (host: {
            name = "${user}@${host}";
            value = (
              f { inherit user host; hostInfo = (getAttr host hosts); });
          })
          (attrNames hosts)))
        users));

      genHosts = f: (genAttrs (attrNames hosts) (host:
        f { inherit host; hostInfo = (getAttr host hosts); }));
    in
    {
      nixosConfigurations = genHosts ({ host, hostInfo, ... }:
        nixosSystem {
          system = hostInfo.system;
          specialArgs = { inherit nixpkgs nixos-hardware private home-manager; };
          modules = [
            ./common.nix
            (./. + "/host/${host}/configuration.nix")
          ];
        }
      );

      homeConfigurations = genUsers ({ user, hostInfo, ... }:
        home-manager.lib.homeManagerConfiguration {
          system = "${hostInfo.system}";
          homeDirectory = "/home/${user}";
          username = "${user}";
          stateVersion = "21.11";
          configuration = import ./user/${user}/home.nix;
        }
      );
    };
}
