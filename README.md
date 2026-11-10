# claude-low-quota

Automatic low-quota mode for [Claude Code](https://claude.com/claude-code).

When your 5-hour or 7-day Claude usage passes a threshold (default 80% used, i.e. 20% left), Claude switches to a working mode that spends almost no Claude quota:

- **Implementation** goes to external coding agents — [Antigravity](https://antigravity.google) (`agy`, Gemini) or [opencode](https://opencode.ai) — each in its own [herdr](https://herdr.dev) tab and git worktree.
- **Review + merge** is done by one Claude `sonnet` subagent per PR, which sends findings back to the same external agent through herdr until the PR is clean.
- **Claude** only writes handoff prompts, launches, watches, and relays short results.
- External agents end with `HANDOFF-DONE PR #N`; a background watcher notices and Claude dispatches the reviewer automatically — no need to poke it.

## How it works

1. Your status line already receives `rate_limits.five_hour.used_percentage` and `rate_limits.seven_day.used_percentage`. `statusline-snippet.sh` writes them to `~/.claude/state/usage.json`.
2. `hooks/low-quota.sh` (a `UserPromptSubmit` hook) reads that file on every prompt and, above the threshold, tells Claude to load the `low-quota` skill.
3. `skills/low-quota/SKILL.md` is the procedure; `skills/low-quota/watch.sh` is the completion watcher.

You can also switch manually with `/low-quota`.

## Install

Requires `jq`, `herdr`, and at least one of `agy` / `opencode`.

```bash
mkdir -p ~/.claude/skills ~/.claude/hooks
cp -r skills/low-quota ~/.claude/skills/
cp hooks/low-quota.sh ~/.claude/hooks/ && chmod +x ~/.claude/hooks/low-quota.sh ~/.claude/skills/low-quota/watch.sh
```

1. Paste `statusline-snippet.sh` into your status line script (see `statusLine` in `~/.claude/settings.json`).
2. Register the hook in `~/.claude/settings.json`:

```json
"hooks": {
  "UserPromptSubmit": [
    { "hooks": [ { "type": "command", "command": "bash ~/.claude/hooks/low-quota.sh" } ] }
  ]
}
```

Change the threshold with `LOW_QUOTA_THRESHOLD` (percent used, default `80`).

## License

MIT
