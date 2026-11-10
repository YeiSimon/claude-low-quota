#!/bin/bash
# UserPromptSubmit hook: when 5h or 7d usage is >= threshold, nudge Claude into low-quota mode
# for implementation work. Opt out per session (LOW_QUOTA_DISABLE=1) or per project
# (a .claude/no-low-quota file in the project or any parent directory).
[ "${LOW_QUOTA_DISABLE:-0}" = "1" ] && exit 0
input=$(cat)
dir=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null); dir=${dir:-$PWD}
while [ -n "$dir" ] && [ "$dir" != "/" ]; do
  [ -e "$dir/.claude/no-low-quota" ] && exit 0
  dir=$(dirname "$dir")
done
f="$HOME/.claude/state/usage.json"; [ -f "$f" ] || exit 0
read -r five week < <(jq -r '[.five_hour // 0, .seven_day // 0] | map(floor) | @tsv' "$f" 2>/dev/null) || exit 0
th=${LOW_QUOTA_THRESHOLD:-80}
if [ "${five:-0}" -ge "$th" ] || [ "${week:-0}" -ge "$th" ]; then
  echo "LOW QUOTA: Claude usage is high (5h ${five}% used, 7d ${week}% used; threshold ${th}%). This applies only to code implementation work (writing features/fixes, opening PRs): for that, load the low-quota skill — implementation goes to agy (Gemini) / opencode via herdr, a sonnet subagent reviews and merges, you only coordinate. Do NOT switch for research, analysis, questions, writing or design discussion — just keep those answers lean. When you do switch, tell the user in one line."
fi
exit 0
