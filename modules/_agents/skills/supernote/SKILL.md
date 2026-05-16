---
name: supernote
description: Look at notes made on the user's Supernote device via the supernote cloud CLI. Use when the user wants to list, read, download, or sync notes from their Supernote device.
---

# Supernote Skill

Use the `supernote` CLI to interact with the user's Supernote cloud account. The binary is installed via `pkgs.supernote-cli` in their nixpkgs overlay.

If `supernote` is not in PATH, try `direnv exec . supernote <args>` from `~/.config/nixpkgs`, or look up the store path from `nix build .#legacyPackages.x86_64-linux.supernote-cli --print-out-paths`.

---

## Subcommands

### Auth
```sh
supernote login          # authenticate and cache token
supernote logout         # delete cached token
supernote whoami         # show cached account and token age
```

### Browse & Download
```sh
supernote ls [path]              # list folder contents (default: root)
supernote ls --json [path]       # JSON output
supernote download <path>        # download file by remote path, e.g. Note/Inbox/foo.note
supernote download --by-id <id>  # download by file id
supernote download -o <out> <path>  # write to specific local path
```

### Upload & Delete
```sh
supernote upload <local> <remote_dir>            # upload local file to remote dir
supernote upload --overwrite <local> <remote_dir>
supernote delete <path> [<path>...]              # delete remote file(s) by path
supernote delete --by-id <id>                   # delete by id (repeatable)
```

### Sync
```sh
supernote sync -o <local_dir> <remote_path>          # mirror folder locally
supernote sync -o <local_dir> --recursive <path>     # include subdirectories
supernote sync -o <local_dir> --days-ago 7 <path>    # only files modified in last N days
supernote sync -o <local_dir> --dry-run <path>       # preview without downloading
```

### Notes (`.note` files)
```sh
supernote note ls                    # list .note files under /Note/
supernote note ls --days-ago 14      # recently modified only
supernote note ls --json             # JSON table output
supernote note <target>              # print device OCR transcript per page
                                     # target: basename (foo.note or foo),
                                     #         full path (Note/sub/foo.note),
                                     #         or numeric file id
supernote note <target> -o <dir>     # also save page_N.png images
supernote note <target> --ocr ollama # use local Ollama vision OCR instead
supernote note <target> --ocr ollama --model qwen3-vl:8b
supernote note <target> --force      # re-render and re-OCR even if cached
```

### Digests (highlights & annotations)
```sh
supernote digest ls                       # list digest summary records
supernote digest ls --days-ago 30         # recent digests only
supernote digest ls --json
supernote digest <id>                     # print blockquoted highlight as markdown
supernote digest <id1>,<id2>             # multiple comma-separated ids
supernote digest <id> -o <path.png>      # also save handwriting PNG
supernote digest <id> -o <dir>           # save as {digest_id}.png in dir
supernote digest <id> --ocr ollama       # transcribe handwriting via Ollama
supernote digest <id> --force            # re-render and re-OCR
```

### Source documents (books/PDFs with digests)
```sh
supernote source ls                  # list source documents that have digests
supernote source ls --days-ago 30
supernote source ls --json
```

### Global flags
```sh
supernote --no-cache <cmd>           # ignore and skip writing token cache
supernote --verbose <cmd>            # print HTTP calls
supernote --equipment-no <n> <cmd>   # override SUPERNOTE_EQUIPMENT_NO
```

---

## Common workflows

**Read a recent note:**
```sh
supernote note ls --days-ago 7      # find recent notes
supernote note foo.note             # print OCR transcript
```

**Pull all recent digests:**
```sh
supernote digest ls --days-ago 14
supernote digest <id>
```

**Sync notes folder locally:**
```sh
supernote sync -o ~/supernote --recursive Note
```
