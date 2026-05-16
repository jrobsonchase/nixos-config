# Environment
I use NixOS, so tools may not be globally installed. If a command is missing, first try running it via `direnv exec . <command>` to use the nix/direnv environment for the current workspace.

# Source Control
This user uses [jujutsu (jj)](https://github.com/jj-vcs/jj) for source control. Git is the backing store but the working copy and history are managed by jj, so raw `git` commands may behave unexpectedly or conflict with jj's state.

- **Prefer `jj` over `git`** for all SCM operations: status, log, diff, commit, branch management, etc.
- Use `jj st` instead of `git status`, `jj log` instead of `git log`, `jj diff` instead of `git diff`, `jj commit` / `jj describe` instead of `git commit`, etc.
- For GitHub operations (push, PR creation), `jj git push` is the correct command.
- Avoid `git add`, `git commit`, `git reset`, or `git checkout` — these can corrupt jj's working-copy state.
- If a tool or script requires git, verify it won't conflict with jj before running it.
- **Always ask before rebasing or abandoning commits** — these rewrite history and may be destructive.
