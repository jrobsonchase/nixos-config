{ self, ... }:
{
  flake.homeModules.pi =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.agents
      ];

      home.packages = with pkgs; [
        pi
      ];
      home.file.".pi/agent/AGENTS.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/AGENTS.md";

    };
}
