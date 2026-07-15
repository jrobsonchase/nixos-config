{ self, ... }:
{
  flake.homeModules.opencode =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.agents
      ];

      programs.opencode = {
        package = pkgs.llm-agents.opencode2;
        enable = true;
      };

      home.file.".config/opencode/AGENTS.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/AGENTS.md";

      home.file.".config/opencode/skills".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills";
    };
}
