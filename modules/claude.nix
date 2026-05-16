{ self, ... }:
{
  flake.homeModules.claude =
    {
      config,
      ...
    }:
    {
      imports = [
        self.homeModules.agents
      ];

      programs.claude-code.enable = true;

      home.file.".claude/CLAUDE.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/AGENTS.md";

      home.file.".claude/skills".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills";
    };
}
