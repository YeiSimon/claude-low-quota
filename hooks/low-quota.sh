#!/bin/bash
# UserPromptSubmit hook: when 5h or 7d usage is >= 80% (<= 20% left), tell Claude to switch to low-quota mode.
f="$HOME/.claude/state/usage.json"; [ -f "$f" ] || exit 0
read -r five week < <(jq -r '[.five_hour // 0, .seven_day // 0] | map(floor) | @tsv' "$f" 2>/dev/null) || exit 0
th=${LOW_QUOTA_THRESHOLD:-80}
if [ "${five:-0}" -ge "$th" ] || [ "${week:-0}" -ge "$th" ]; then
  echo "LOW QUOTA: Claude usage is high (5h ${five}% used, 7d ${week}% used; threshold ${th}%). Switch to low-quota mode now: load the low-quota skill and follow it — implementation goes to agy (Gemini) / opencode via herdr, a sonnet subagent only reviews and merges, and you only coordinate with minimal tool calls. Tell the user in one line that low-quota mode is on."
fi
exit 0
