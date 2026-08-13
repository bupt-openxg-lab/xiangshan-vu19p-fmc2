#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
RELEASE_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
SESSION_NAME=${SESSION_NAME:-xs-vu19p-fmc2-build}

command -v screen >/dev/null || { echo "ERROR: GNU screen is not installed" >&2; exit 2; }
if screen -ls | awk '{print $1}' | grep -Eq "^[0-9]+\.${SESSION_NAME}$"; then
  echo "ERROR: screen session already exists: $SESSION_NAME" >&2
  exit 3
fi

screen -dmS "$SESSION_NAME" bash -lc \
  "cd '$RELEASE_ROOT' && exec ./scripts/10-build.sh"

echo "SCREEN START RESULT=PASS session=$SESSION_NAME"
echo "Attach: screen -r $SESSION_NAME"
echo "Live log: tail -f $RELEASE_ROOT/logs/latest-build.log"

