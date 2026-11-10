# Add to your Claude Code statusLine script, after reading stdin into $input.
# Persists the rate-limit usage so hooks/low-quota.sh can read it.
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
mkdir -p "$HOME/.claude/state" 2>/dev/null
printf '{"five_hour":%s,"seven_day":%s,"ts":%s}\n' "${five:-null}" "${week:-null}" "$(date +%s)" > "$HOME/.claude/state/usage.json" 2>/dev/null
