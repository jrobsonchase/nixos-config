---
name: github
description: Use GitHub CLI (gh) for GitHub operations. Covers issues, pull requests, repositories, releases, and more.
---

# GitHub CLI Skill

Use `gh` (GitHub CLI) for all GitHub operations including issues, pull requests, repositories, gists, and workflows.

## Repository Context

**If the repository uses `jj` (jujutsu)**: Use `jj` commands to inspect repository state (branches, diffs, commits, status) instead of `git` commands. The `gh` CLI is still used for GitHub API operations (issues, PRs, etc.), but local repository inspection should use jujutsu.

**When creating pull requests**: Assume branches have already been pushed. Do not attempt to push branches before creating PRs.

## Prerequisites

The GitHub CLI must be authenticated. Check with:
```sh
gh auth status
```

If not authenticated, run:
```sh
gh auth login
```

## Common Operations

### Issues

```sh
# List issues
gh issue list --repo OWNER/REPO                    # list open issues
gh issue list --repo OWNER/REPO --state all        # list all issues
gh issue list --repo OWNER/REPO --limit 10         # limit results
gh issue list --repo OWNER/REPO --label bug        # filter by label
gh issue list --repo OWNER/REPO --assignee USER    # filter by assignee

# View issue details
gh issue view NUMBER --repo OWNER/REPO             # view issue
gh issue view NUMBER --repo OWNER/REPO --json title,body,labels,state
gh issue view NUMBER --repo OWNER/REPO --web       # open in browser

# Create issue
gh issue create --repo OWNER/REPO --title "Title" --body "Description"
gh issue create --repo OWNER/REPO --title "Title" --body "Description" --label bug,enhancement

# Edit/close issue
gh issue edit NUMBER --repo OWNER/REPO --title "New title"
gh issue close NUMBER --repo OWNER/REPO
gh issue reopen NUMBER --repo OWNER/REPO

# Comment on issue
gh issue comment NUMBER --repo OWNER/REPO --body "Comment text"
```

### Pull Requests

**Important**: 
- When creating PRs, assume the branch has already been pushed. Do not run git/jj push commands.
- Branches may not be pushed to `origin` - verify which remote the branch exists on before creating PRs.
- For jj repos: use `jj git fetch` and `jj log -r 'remote_branches()'` or `jj bookmark list --all` to see remote branches.
- For git repos: use `git branch -r` to see remote branches.

```sh
# List pull requests
gh pr list --repo OWNER/REPO                       # list open PRs
gh pr list --repo OWNER/REPO --state all           # list all PRs
gh pr list --repo OWNER/REPO --limit 10            # limit results
gh pr list --repo OWNER/REPO --author USER         # filter by author

# View PR details
gh pr view NUMBER --repo OWNER/REPO                # view PR
gh pr view NUMBER --repo OWNER/REPO --json title,body,state,mergeable
gh pr view NUMBER --repo OWNER/REPO --web          # open in browser

# Create PR
gh pr create --repo OWNER/REPO --title "Title" --body "Description"
gh pr create --repo OWNER/REPO --title "Title" --body "Description" --base main --head feature-branch

# PR operations
gh pr checkout NUMBER --repo OWNER/REPO            # checkout PR locally
gh pr merge NUMBER --repo OWNER/REPO               # merge PR
gh pr close NUMBER --repo OWNER/REPO               # close PR
gh pr reopen NUMBER --repo OWNER/REPO              # reopen PR
gh pr review NUMBER --repo OWNER/REPO --approve    # approve PR
gh pr review NUMBER --repo OWNER/REPO --comment --body "Review comment"

# Comment on PR
gh pr comment NUMBER --repo OWNER/REPO --body "Comment text"
```

### Repositories

```sh
# View repository
gh repo view OWNER/REPO                            # view repo info
gh repo view OWNER/REPO --json name,description,stargazersCount,forksCount
gh repo view OWNER/REPO --web                      # open in browser

# Clone repository
gh repo clone OWNER/REPO                           # clone repo

# Create repository
gh repo create NAME --public                       # create public repo
gh repo create NAME --private                      # create private repo

# Fork repository
gh repo fork OWNER/REPO                            # fork repo
gh repo fork OWNER/REPO --clone                    # fork and clone

# List repositories
gh repo list OWNER                                 # list user/org repos
gh repo list OWNER --limit 10                      # limit results
```

### Releases

```sh
# List releases
gh release list --repo OWNER/REPO                  # list releases
gh release list --repo OWNER/REPO --limit 10       # limit results

# View release
gh release view TAG --repo OWNER/REPO              # view release
gh release view TAG --repo OWNER/REPO --json tagName,name,body,assets

# Create release
gh release create TAG --repo OWNER/REPO --title "v1.0.0" --notes "Release notes"
gh release create TAG --repo OWNER/REPO --title "v1.0.0" --notes "Release notes" FILE1 FILE2

# Download release assets
gh release download TAG --repo OWNER/REPO          # download all assets
gh release download TAG --repo OWNER/REPO --pattern "*.tar.gz"
```

### Workflows (GitHub Actions)

```sh
# List workflows
gh workflow list --repo OWNER/REPO                 # list workflows

# View workflow runs
gh run list --repo OWNER/REPO                      # list recent runs
gh run list --repo OWNER/REPO --limit 10           # limit results
gh run list --repo OWNER/REPO --workflow "CI"      # filter by workflow

# View run details
gh run view RUN_ID --repo OWNER/REPO               # view run
gh run view RUN_ID --repo OWNER/REPO --log         # view logs

# Trigger workflow
gh workflow run WORKFLOW --repo OWNER/REPO         # trigger workflow
```

### Gists

```sh
# List gists
gh gist list                                       # list your gists
gh gist list --limit 10                            # limit results

# Create gist
gh gist create FILE                                # create gist from file
gh gist create --public FILE                       # create public gist
gh gist create --desc "Description" FILE           # with description

# View gist
gh gist view GIST_ID                               # view gist
gh gist view GIST_ID --web                         # open in browser
```

### Search

```sh
# Search repositories
gh search repos QUERY                              # search repos
gh search repos "machine learning" --language python
gh search repos "topic:react" --stars ">1000"

# Search issues
gh search issues QUERY                             # search issues
gh search issues "is:open label:bug repo:OWNER/REPO"

# Search pull requests  
gh search prs QUERY                                # search PRs
gh search prs "is:open repo:OWNER/REPO"
```

## Output Formats

Use `--json` flag with field names to get structured output:

```sh
# JSON output
gh issue list --repo OWNER/REPO --json number,title,state,labels

# Template output
gh issue list --repo OWNER/REPO --json number,title --template '{{range .}}{{.number}}: {{.title}}{{"\n"}}{{end}}'
```

## Tips

1. **Use `--repo` flag**: Specify repository explicitly to avoid context ambiguity
2. **JSON output**: Use `--json` for structured data that's easier to parse
3. **Pagination**: Use `--limit` to control result count (default is usually 30)
4. **Authentication**: Ensure `gh auth status` shows you're logged in
5. **Help**: Use `gh COMMAND --help` for detailed command help

## Common Patterns

### Get first N issues
```sh
gh issue list --repo OWNER/REPO --limit 5 --json number,title,state
```

### Search for specific issues
```sh
gh search issues "is:open label:bug repo:OWNER/REPO" --limit 10 --json number,title
```

### Get PR status
```sh
gh pr status --repo OWNER/REPO
```

### View recent workflow runs
```sh
gh run list --repo OWNER/REPO --limit 5 --json status,conclusion,name,createdAt
```
