---
name: obsidian
description: Manage Obsidian notes, daily notes, tasks, tags, properties, and vault contents using obsidian-cli. Use when the user wants to read, create, edit, search, or organize notes in Obsidian.
---

# Obsidian Notes Skill

Use `obsidian-cli` (invoked as `obsidian`) to interact with the user's Obsidian vault. On NixOS, if `obsidian` is not in PATH, use `direnv exec . obsidian <command>`.

## Key Patterns

**File resolution:** `file=<name>` resolves by name (like wikilinks); `path=<path>` is an exact vault-relative path. Quote values with spaces. Use `\n` for newlines in content.

**Target a specific vault:** prepend `vault=<name>` to any command.

---

## Common Operations

### Reading & Searching
```sh
obsidian read file="Note Name"
obsidian search query="search terms"
obsidian search:context query="search terms"   # includes surrounding lines
obsidian files folder="folder/path"
obsidian folders
```

### Creating & Editing
```sh
obsidian create name="New Note" content="body text"
obsidian create name="New Note" template="Template Name"
obsidian append file="Note Name" content="new content"
obsidian prepend file="Note Name" content="new content"
obsidian move file="Note Name" to="folder/path"
obsidian rename file="Note Name" name="New Name"
obsidian delete file="Note Name"
```

### Daily Notes
```sh
obsidian daily:read                             # read today's daily note
obsidian daily:append content="text to add"    # append to today's daily note
obsidian daily:prepend content="text to add"
obsidian daily:path                             # get the file path
```

### Tasks
```sh
obsidian tasks                                  # list all tasks
obsidian tasks todo                             # incomplete only
obsidian tasks done                             # completed only
obsidian tasks file="Note Name"                 # tasks in a specific note
obsidian task file="Note Name" line=5 toggle    # toggle a specific task
obsidian task file="Note Name" line=5 done      # mark done
```

### Properties / Frontmatter
```sh
obsidian properties file="Note Name"
obsidian property:read name="status" file="Note Name"
obsidian property:set name="status" value="done" file="Note Name"
obsidian property:remove name="status" file="Note Name"
```

### Tags & Links
```sh
obsidian tags file="Note Name"
obsidian tags counts sort=count
obsidian links file="Note Name"                 # outgoing links
obsidian backlinks file="Note Name"
obsidian orphans                                # files with no incoming links
obsidian unresolved                             # broken links
```

### Vault Info
```sh
obsidian vault
obsidian vaults verbose
obsidian files total
obsidian outline file="Note Name"
obsidian wordcount file="Note Name"
```

### Templates
```sh
obsidian templates
obsidian template:read name="Template Name"
```

---

## TODO Workflow (Daily Note)

Tasks live in the **daily note**, not a dedicated TODO note. Always use daily note commands for todo operations.

### Task format

Each todo item uses this structure:
```
- [ ] Task description
  - Added: YYYY-MM-DD
  - Due: YYYY-MM-DD        ← only if a due date was provided
  - [ ] Sub-task           ← optional sub-tasks below the date bullets
  - [ ] Another sub-task
```

Completed items use `- [x]` in place.

### Adding a TODO item

1. **Always read first:** `obsidian daily:read` — check for duplicates before adding.
2. Append the new item with today's date:
   ```sh
   obsidian daily:append content="- [ ] Task description\n  - Added: YYYY-MM-DD"
   # With due date:
   obsidian daily:append content="- [ ] Task description\n  - Added: YYYY-MM-DD\n  - Due: YYYY-MM-DD"
   ```

### Listing TODO items

```sh
obsidian daily:read                         # read full daily note
obsidian tasks todo file="YYYY-MM-DD"      # incomplete items (use today's date as filename)
obsidian tasks done file="YYYY-MM-DD"      # completed items
```

### Completing a TODO item

1. Read the daily note to find the line number: `obsidian daily:read`
2. Toggle the checkbox: `obsidian task file="YYYY-MM-DD" line=<N> done`

### Starting a new day

When the user starts a new day or a fresh daily note is created:

1. Find the most recent previous daily note: `obsidian files folder="Daily"` (sorted by name, pick the last one before today)
2. Read it: `obsidian read file="YYYY-MM-DD"`
3. Extract all incomplete tasks (`- [ ]`) and their sub-bullets (`Added:`, `Due:`) exactly as written
4. Read today's daily note: `obsidian daily:read`
5. Append the carried-over tasks to today's note, preserving the original `Added:` and `Due:` dates verbatim — do not update them to today's date

---

## Guidelines

- Prefer `file=` (wikilink-style resolution) over `path=` unless the user provides an exact path.
- When appending structured content (like meeting notes or log entries), use `\n` for newlines.
- For bulk operations (e.g., tag all notes in a folder), combine `obsidian files folder=...` output with loops.
- Use `format=json` when you need to parse output programmatically.
- Always confirm before deleting notes or restoring history versions.
- **`.note` files must include the extension in wikilinks.** These are SuperNote handwritten notes synced via an Obsidian plugin. Without the extension, the link resolves to a nonexistent `.md` file with the same base name. Always write `[[Note Name.note]]`, never `[[Note Name]]`.
