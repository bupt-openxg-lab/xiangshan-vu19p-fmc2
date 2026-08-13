#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

if [[ ! -f "$XPR" ]]; then
  echo "STATUS: Vivado project not generated"
  exit 0
fi

vivado -mode batch -nojournal -nolog -notrace \
  -source "$RELEASE_ROOT/tcl/query_status.tcl" -tclargs "$XPR"

if [[ -L "$LOG_DIR/latest-build.log" ]]; then
  echo
  echo "Latest build log: $(readlink -f "$LOG_DIR/latest-build.log")"
  tail -n 25 "$LOG_DIR/latest-build.log"
fi

