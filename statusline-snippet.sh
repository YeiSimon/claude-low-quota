# Add to your Claude Code statusLine script, after reading stdin into $input.
# Persists the rate-limit usage, and when each window resets, so hooks/low-quota.sh
# can tell a stale reading from a live one.
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
# resets_at may be an epoch or an ISO-8601 string; normalise to epoch seconds (empty if unknown).
to_epoch() { case "$1" in ''|null) ;; *[!0-9]*) date -d "$1" +%s 2>/dev/null || date -j -f '%Y-%m-%dT%H:%M:%S' "${1%%[.Z+]*}" +%s 2>/dev/null ;; *) echo "$1" ;; esac; }
five_reset=$(to_epoch "$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')")
week_reset=$(to_epoch "$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')")
mkdir -p "$HOME/.claude/state" 2>/dev/null
printf '{"five_hour":%s,"seven_day":%s,"five_hour_resets_at":%s,"seven_day_resets_at":%s,"ts":%s}\n' \
  "${five:-null}" "${week:-null}" "${five_reset:-null}" "${week_reset:-null}" "$(date +%s)" \
  > "$HOME/.claude/state/usage.json" 2>/dev/null
