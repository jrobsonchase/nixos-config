{ self, inputs, ... }:
let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (self.lib)
    genUsers
    liftAttr
    ;

  inputHomeModules = liftAttr "homeManagerModules" inputs;

in
{
  flake.homeConfigurations = (
    genUsers (
      {
        username,
        system,
        host,
        ...
      }:
      homeManagerConfiguration {
        pkgs = self.legacyPackages.${system};
        extraSpecialArgs = {
          inherit self;
          inputModules = inputHomeModules;
          flakeModulesPath = self + "/home/modules";
          myModulesPath = self + "/home/users/${username}/modules";
          flakeSecretsPath = self + "/secrets";
        };
        modules = [
          {
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
              stateVersion = "21.11";
            };
          }
          (self + "/home/users/${username}/hosts/${host}")
        ];
      }
    )
  );
}
