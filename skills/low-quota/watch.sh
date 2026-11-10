#!/bin/zsh
# Exit (and so notify the coordinator) as soon as any watched agent prints a HANDOFF marker.
agents=("$@")
while true; do
  for a in $agents; do
    out=$(herdr agent read $a --lines 60 2>/dev/null)
    [ -n "$WATCH_IGNORE" ] && out=$(print -r -- "$out" | grep -v -E "$WATCH_IGNORE")
    if print -r -- "$out" | grep -q -E 'HANDOFF-DONE PR #[0-9]+|HANDOFF-BLOCKED [^<]'; then
      print "FINISHED $a"; print -r -- "$out" | grep -E 'HANDOFF-DONE PR #[0-9]+|HANDOFF-BLOCKED [^<]' | tail -1; exit 0
    fi
  done
  sleep 60
done
