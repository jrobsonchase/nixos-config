#!/usr/bin/env bash
#
# Zed's `create_worktree` hook (see programs.zed-editor.userTasks in zed.nix).
#
# Zed creates linked worktrees with `git worktree add`, which Jujutsu does not
# know about. In a colocated repo that leaves the new checkout outside `jj
# workspace list`, so work done there is invisible to jj and the colocated Git
# metadata can drift.
#
# When the original checkout is a colocated jj repo, replace Zed's linked Git
# worktree with a real jj workspace. `--colocate` makes jj create the matching
# Git worktree again, so Zed keeps working as usual. This mirrors the approach
# in the OpenCode `jj-worktree` plugin.
#
# Non-jj and non-colocated repos are left untouched.

set -euo pipefail

main=${ZED_MAIN_GIT_WORKTREE:-}
root=${ZED_WORKTREE_ROOT:-}

# The hook also fires for plain Git repos, where Zed's worktree is already fine.
[ -n "$main" ] && [ -n "$root" ] || exit 0
[ -d "$main/.jj" ] && [ -d "$main/.git" ] || exit 0
[ -d "$root" ] || exit 0
command -v jj >/dev/null 2>&1 || exit 0

main=$(cd "$main" && pwd -P)
root=$(cd "$root" && pwd -P)

# Don't touch the root workspace or a directory that is already a jj workspace
# (relevant when the task is run by hand from the task modal).
[ "$root" = "$main" ] && exit 0
[ -d "$root/.jj" ] && exit 0

workspace_roots=$(jj --repository "$main" workspace list -T 'root ++ "\n"')
if grep -Fxq -- "$root" <<<"$workspace_roots"; then
  exit 0
fi

# Keep the commit Zed checked out; jj will create a working-copy commit on top.
revision=$(git -C "$root" rev-parse HEAD)

# jj requires unique, reasonably named workspaces. Match the OpenCode plugin:
# use the destination basename, sanitized, with a numeric suffix if needed.
name=$(basename -- "$root" | sed -E 's/[^A-Za-z0-9._-]+/-/g; s/^[-.]+//; s/[-.]+$//')
[ -n "$name" ] || name=worktree

existing_names=$(jj --repository "$main" workspace list -T 'name ++ "\n"')
candidate=$name
suffix=2
while grep -Fxq -- "$candidate" <<<"$existing_names"; do
  candidate="$name-$suffix"
  suffix=$((suffix + 1))
done

# The task starts inside the worktree that is about to be removed.
cd "$main"

git -C "$main" worktree remove --force -- "$root"
jj --repository "$main" workspace add "$root" \
  --name "$candidate" \
  --revision "$revision" \
  --colocate
