# Prune Claude Code's temp root.
#
# Claude Code puts per-session scratch directories under
#   $CLAUDE_CODE_TMPDIR/claude-<uid>/<project-slug>/<session-uuid>/
# and per-session cache state at
#   $CLAUDE_CODE_TMPDIR/claude-<uid>/cache-break-state-<session-uuid>.json
#
# A session is live when ~/.claude/sessions/<pid>.json names it and that pid
# still runs. A session still exists when ~/.claude/projects/<slug>/<uuid>.jsonl
# is present. This script removes the scratch state of every other session, and
# ages out loose temp entries that carry no session id.

import argparse
import json
import os
import re
import shutil
import sys
import time
from pathlib import Path

UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
    re.IGNORECASE,
)
CACHE_BREAK_RE = re.compile(r"^cache-break-state-(.+)\.json$")


def pid_alive(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except (PermissionError, OverflowError, TypeError, ValueError):
        return True
    return True


def live_session_ids(claude_dir):
    # Session ids claimed by a Claude Code process that still runs.
    ids = set()
    for record in (claude_dir / "sessions").glob("*.json"):
        try:
            data = json.loads(record.read_text())
        except (OSError, ValueError):
            # Treat an unreadable record as live, so we never prune blindly.
            continue
        session_id = data.get("sessionId")
        if not session_id:
            continue
        pid = data.get("pid")
        if isinstance(pid, int) and not pid_alive(pid):
            continue
        ids.add(session_id)
    return ids


def known_session_ids(claude_dir):
    # Session ids that still own a transcript.
    return {t.stem for t in (claude_dir / "projects").glob("*/*.jsonl")}


def mtime(path):
    try:
        return path.lstat().st_mtime
    except OSError:
        # Treat an unreadable entry as fresh, so we keep it.
        return time.time()


def remove(path, reason, opts):
    if opts.dry_run:
        print("would remove {} ({})".format(path, reason))
        return
    if opts.verbose:
        print("removing {} ({})".format(path, reason))
    try:
        if path.is_dir() and not path.is_symlink():
            shutil.rmtree(path)
        else:
            path.unlink()
    except OSError as err:
        print("could not remove {}: {}".format(path, err), file=sys.stderr)


def prune_project_dir(project_dir, keep, now, opts):
    for session_dir in sorted(project_dir.iterdir()):
        if session_dir.is_symlink() or not UUID_RE.match(session_dir.name):
            continue
        if session_dir.name in keep:
            continue
        if now - mtime(session_dir) < opts.grace_minutes * 60:
            continue
        remove(session_dir, "session gone", opts)
    if opts.dry_run:
        return
    try:
        project_dir.rmdir()
    except OSError:
        pass


def main():
    parser = argparse.ArgumentParser(description="Prune the Claude Code temp root.")
    parser.add_argument(
        "--grace-minutes",
        type=int,
        default=60,
        help="keep scratch state of an unmatched session this long (default: 60)",
    )
    parser.add_argument(
        "--max-age-days",
        type=int,
        default=7,
        help="remove loose temp entries older than this (default: 7)",
    )
    parser.add_argument("--dry-run", action="store_true", help="only report what would go")
    parser.add_argument("--verbose", action="store_true", help="name each removal")
    opts = parser.parse_args()

    base = os.environ.get("CLAUDE_CODE_TMPDIR")
    if not base:
        sys.exit("CLAUDE_CODE_TMPDIR is not set; refusing to guess the temp root")

    root = Path(base) / "claude-{}".format(os.getuid())
    if root.is_symlink() or not root.is_dir():
        return 0

    claude_dir = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude")
    keep = live_session_ids(claude_dir) | known_session_ids(claude_dir)
    now = time.time()

    for entry in sorted(root.iterdir()):
        if entry.is_symlink():
            continue

        # A project slug directory holds one subdirectory per session.
        if entry.is_dir() and entry.name.startswith("-"):
            prune_project_dir(entry, keep, now, opts)
            continue

        match = CACHE_BREAK_RE.match(entry.name)
        if match and entry.is_file():
            if match.group(1) in keep:
                continue
            if now - mtime(entry) >= opts.grace_minutes * 60:
                remove(entry, "session gone", opts)
            continue

        if now - mtime(entry) > opts.max_age_days * 86400:
            remove(entry, "older than {}d".format(opts.max_age_days), opts)

    return 0


if __name__ == "__main__":
    sys.exit(main())
