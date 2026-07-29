{ self, ... }:
{
  flake.homeModules.claude =
    {
      config,
      pkgs,
      ...
    }:
    let
      # Claude Code appends "claude-<uid>" to this path, so give it a directory
      # of its own: it also becomes TMPDIR for sandboxed child processes.
      tmpDir = "${config.xdg.cacheHome}/claude-tmp";

      prune-tmp = pkgs.writers.writePython3Bin "claude-prune-tmp" {
        flakeIgnore = [ "E501" ];
      } (builtins.readFile ./_claude/prune-tmp.py);
    in
    {
      imports = [
        self.homeModules.agents
      ];

      programs.claude-code.enable = true;

      home.packages = [ prune-tmp ];

      # /tmp is emptied on every boot by boot.tmp.cleanOnBoot, which loses the
      # scratch state of every session. Keep it under the cache directory, which
      # survives a reboot, and prune it on a timer instead.
      home.sessionVariables.CLAUDE_CODE_TMPDIR = tmpDir;

      systemd.user.services.claude-prune-tmp = {
        Unit.Description = "Prune Claude Code scratch state for sessions that are gone";
        Service = {
          Type = "oneshot";
          Environment = [ "CLAUDE_CODE_TMPDIR=${tmpDir}" ];
          ExecStart = "${prune-tmp}/bin/claude-prune-tmp --verbose";
        };
      };

      systemd.user.timers.claude-prune-tmp = {
        Unit.Description = "Prune the Claude Code temp directory hourly";
        Timer = {
          OnStartupSec = "10min";
          OnUnitActiveSec = "1h";
        };
        Install.WantedBy = [ "timers.target" ];
      };

      home.file.".claude/CLAUDE.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/AGENTS.md";

      home.file.".claude/skills".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/skills";

      home.file.".claude/agents".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.agents/agents";
    };
}
