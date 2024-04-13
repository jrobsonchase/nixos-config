{ users, hosts, lib, inputs, ... }:
let
  inherit (builtins) getAttr attrNames listToAttrs concatMap filter hasAttr;
  inherit (lib) genAttrs;
  hostnames = attrNames hosts;

  getHostInfo = hostname: (getAttr hostname hosts) // { inherit hostname; };
in
{
  # Generate a set containing "user@host" attributes using a function.
  # The function is provided `user`, `hostname`, and the contents of the
  # top-level set of host info.
  genUsers =
    let
      genUserForHosts = f: username:
        map (genUserForHost f username) hostnames;
      genUserForHost = f: username: host: {
        name = "${username}@${host}";
        value = (
          f ({ inherit username host; } // (getHostInfo host))
        );
      };
    in
    f: listToAttrs (concatMap (genUserForHosts f) users);

  # Generate a set of hosts using a function.
  # The function is provided `hostname` and the contents of the
  # top-level set of host info.
  genHosts =
    let
      genHost = f: host:
        f (getHostInfo host);
    in
    f: genAttrs hostnames (genHost f);

  # *Probably* exists somewhere already, but takes the named sub-attribute of
  # each top-level attribute, and lifts it to the top-level under its parent's name.
  # Attrs lacking the named sub-attribute are pruned.
  # Example:
  # ```
  # liftAttr "nixosModules" {
  #   home-manager = { nixosModules = { foo = ...; }; ... };
  #   nixos-hardware = { nixosModules = { bar = ...; }; ... };
  #   noModules = { ... };
  # }
  # Returns:
  # {
  #   home-manager = { foo = ...; };
  #   nixos-hardware = { bar = ...; };
  # }
  # ```
  liftAttr = a: inputs:
    listToAttrs
      (
        map (name: { inherit name; value = getAttr a (getAttr name inputs); })
          (filter (k: (hasAttr a (getAttr k inputs))) (attrNames inputs))
      );

  genNixosHydraJobs = configs: listToAttrs (map
    (name: {
      inherit name;
      value = configs.${name}.config.system.build.toplevel;
    })
    (attrNames configs));
  genHomeManagerHydraJobs = configs: listToAttrs (map
    (name: {
      inherit name;
      value = configs.${name}.activationPackage.overrideAttrs (attrs: { inherit name; });
    })
    (attrNames configs));
} // lib // import ./kdl.nix { inherit lib; }
