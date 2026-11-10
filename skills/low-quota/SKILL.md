---
name: low-quota
description: Low Claude-quota working mode. Use when the low-quota hook fires (5h or 7d usage >= 80%), when a usage-limit warning appears, or when the user says tokens/usage are running out. External tools (agy = Antigravity/Gemini, opencode) do the implementation in herdr tabs; a sonnet subagent only reviews and merges; Claude only coordinates.
---

# Low-quota mode

Goal: keep work moving while spending as little Claude quota as possible.

## Roles
- **Implementation:** `agy` (Antigravity, Gemini) or `opencode`, each in its own herdr tab and git worktree.
- **Review + merge (+ deploy if the repo requires it):** one `sonnet-engineer` subagent per PR. It sends findings back to the same external agent through herdr and re-reviews until clean.
- **Claude (you):** write the handoff prompts, launch, watch, dispatch the reviewer, relay short results. No file reading or investigation of your own beyond what is needed to brief.

## Steps
1. Stop any running Claude implementer subagents (TaskStop); their worktrees keep uncommitted work.
2. Write one prompt file per task (scratchpad). Each prompt: goal, files/issue, tests to run, "commit, push, open/update the PR, do NOT merge or deploy", repo safety rules, and end with:
   `When you are completely finished, end your final message with a line containing exactly: HANDOFF-DONE PR #<number>. If blocked and need a human, end with: HANDOFF-BLOCKED <reason>.`
3. Launch each in its own tab (split panes are too narrow for opencode):
   ```
   id=$(herdr tab create --workspace <ws> --cwd <worktree> --label "<task>" | python3 -c 'import sys,json;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
   herdr agent start <name> --kind agy|opencode --pane $id
   # agy asks to trust the folder on first start: herdr agent send-keys <name> Enter
   herdr agent prompt <name> "$(cat <prompt file>)"
   # opencode: also herdr agent send-keys <name> Enter
   ```
   Check `herdr agent get <name>` shows working. Do not use nohup / --dangerously-skip-permissions from Bash (blocked by the auto-mode classifier).
4. Watch in the background (Bash run_in_background) so results come back without the user asking:
   `bash ~/.claude/skills/low-quota/watch.sh <name1> <name2> ...` — exits printing `FINISHED <name>` and the marker line. Restart it for the remaining agents each time it exits.
5. On `HANDOFF-DONE PR #N`: launch a sonnet-engineer reviewer with: the PR, the author agent's herdr name, what must hold, tests to run, the fix loop (`herdr agent prompt <name> "<findings; fix, push, end with HANDOFF-DONE PR #N>"`, `herdr agent wait <name>`, `herdr agent read <name> --lines 60`), then merge (and deploy per the repo's rules). When two PRs deploy the same component, tell both reviewers to build from the latest main and check live tags first.
6. After merge: close the herdr pane/tab and remove the worktree.
7. Report to the user in a few lines per PR.
