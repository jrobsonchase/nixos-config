---
name: jj
description: jujutsu (jj) for source control operations. Prefer over git for all SCM tasks in repos where jj is in use. Covers status, log, committing, branching (bookmarks), rebasing, history editing, and pushing.
---

# Jujutsu (jj) Skill

Use `jj` for all source control operations in repos where it is enabled. Git is the backing store but jj manages the working copy and history — raw git commands can corrupt jj's state.

Check for the existence of the `$(git rev-parse --show-toplevel)/.jj` directory to know if it's being used.

## Key Concepts

- **Working copy (`@`)**: The current uncommitted changes. jj snapshots it automatically at each command.
- **Change ID vs Commit ID**: Every change has a stable change ID (e.g. `qpvuntsm`) that persists across rewrites, and a commit ID (SHA) that changes when content changes. Use change IDs in revsets.
- **Revsets**: jj uses a query language for selecting revisions (e.g. `@`, `@-`, `main..@`, `trunk()..`).
- **Bookmarks**: jj's equivalent of git branches. Use `jj bookmark` (alias: `jj b`).
- **Immutable commits**: Commits reachable from `trunk()` / `main@origin` are immutable by default. Use `--ignore-immutable` only when absolutely necessary.
- **No staging area**: All working copy changes are automatically included. Use `jj split` or `jj squash -i` to selectively commit.

---

## Common Operations

### Status & Inspection
```sh
jj st                              # working copy status
jj log                             # history graph (mutable commits only)
jj log -r ::                       # full history
jj log -r 'trunk()..@'            # commits since trunk
jj show                            # show current working copy diff
jj show <rev>                      # show a specific revision
jj diff                            # diff of working copy
jj diff -r <rev>                   # diff of a specific revision
jj diff --from <rev1> --to <rev2>  # diff between two revisions
```

### Committing
```sh
jj desc -m "commit message"        # set description on working copy (alias for describe)
jj describe -m "commit message"    # set description on working copy (like git commit --amend -m)
jj commit -m "commit message"      # describe + create new empty change on top (alias: ci)
jj new                             # create a new empty change on top of @
jj new <rev>                       # create a new change on top of a specific revision
jj new <rev1> <rev2>               # create a merge commit
```

### Editing History
```sh
jj split                           # interactively split current change into two
jj split -r <rev>                  # split a specific revision
jj squash                          # move working copy changes into parent
jj squash -i                       # interactively choose which changes to squash
jj squash --from <rev> --into <rev> # move changes between specific revisions
jj absorb                          # auto-route changes into the appropriate ancestor
jj rebase -d <destination>         # rebase current branch onto destination (ASK FIRST)
jj rebase -r <rev> -d <dest>       # rebase a specific revision onto a destination (ASK FIRST)
jj rebase -r <rev> -(B|A) <target> # rebase a specific revision, inserting it Before or After <target> (ASK FIRST)
jj rebase -s <rev> -d <dest>       # rebase a revision and all its descendants (ASK FIRST)
jj abandon <rev>                   # abandon (drop) a revision (ASK FIRST)
jj undo                            # undo the last operation
jj op log                          # operation history
jj op undo <op-id>                 # undo a specific operation
```

### Navigating
```sh
jj edit <rev>                      # set working copy to a specific revision
jj next                            # move working copy to child revision
jj prev                            # move working copy to parent revision
```

### Bookmarks (Branches)
```sh
jj b list                          # list all bookmarks
jj b create <name>                 # create bookmark at current revision
jj b create <name> -r <rev>        # create bookmark at specific revision
jj b set <name>                    # move bookmark to current revision
jj b set <name> -r <rev>           # move bookmark to specific revision
jj b delete <name>                 # delete a bookmark
jj b track <name>@origin           # start tracking a remote bookmark
```

### Git / Remote Operations
```sh
jj git fetch                       # fetch from remote (like git fetch)
jj git fetch --remote origin       # fetch from specific remote
jj git push                        # push current bookmark to remote
jj git push --bookmark <name>      # push a specific bookmark
jj git push --change @             # create/push a bookmark for the current change
jj git push --all                  # push all bookmarks
```

### Conflict Resolution
```sh
jj resolve                         # open merge tool for conflicted files
jj resolve --list                  # list files with conflicts
```

### Files
```sh
jj file list                       # list tracked files
jj restore --from <rev> <path>     # restore a path from another revision
```

---

## Revset Cheatsheet

| Revset | Meaning |
|--------|---------|
| `@` | Working copy |
| `@-` | Parent of working copy |
| `trunk()` | The main/master branch tip |
| `trunk()..@` | All commits between trunk and working copy |
| `<rev>::` | A revision and all its descendants |
| `::<rev>` | A revision and all its ancestors |
| `<rev1>..<rev2>` | Commits reachable from rev2 but not rev1 |
| `bookmarks()` | All bookmark targets |
| `mutable()` | All mutable (non-immutable) commits |

---

## Guidelines

- **Never use `git commit`, `git reset`, or `git checkout`** — these corrupt jj's working-copy state.
- **Always ask before rebasing or abandoning commits** — these rewrite history and may be destructive.
- Use `jj desc` / `jj describe` to amend a commit message without creating a new change.
- Use `jj split` to interactively break a large change into smaller commits.
- Use `jj undo` freely — jj keeps full operation history and everything is recoverable.
- When rebasing, prefer `jj rebase -d trunk()` to update to latest main.
- `jj git push --named <new branch name>=@` is the easiest way to push a single change as a PR branch.
- If you get branch protection errors when pushing to `origin`, check for the existence of a `fork` remote instead.
