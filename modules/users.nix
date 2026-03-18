{ self, inputs, ... }:
let
  inherit (self.lib)
    genUsers
    liftAttr
    homeConfiguration
    ;

  inputHomeModules = liftAttr "homeManagerModules" inputs;

in
{
  flake.homeConfigurations = genUsers (
    {
      username,
      host,
      system,
      ...
    }:
    homeConfiguration username system (self + "/home/users/${username}/hosts/${host}")
  );
}
