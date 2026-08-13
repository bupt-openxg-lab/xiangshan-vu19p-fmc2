#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths
"$SCRIPT_DIR/03-audit-source.sh"

if [[ -d "$PRJ_DIR" && ! -f "$XPR" ]]; then
  echo "ERROR: partial project directory exists: $PRJ_DIR" >&2
  echo "Move it aside manually; this script never deletes projects." >&2
  exit 3
fi

if [[ ! -f "$XPR" ]]; then
  make -C "$FPGA_DIR" all \
    CORE_DIR="$CORE_DIR" CPU=kmh SUFFIX=default-fmc2 \
    NO_DIFF=1 DDR_RANK_WIDTH=1 VIVADO_JOBS="$VIVADO_JOBS" \
    VIVADO_SYNTH_THREADS="$VIVADO_SYNTH_THREADS"
fi

vivado -mode batch -nojournal -nolog -notrace \
  -source "$RELEASE_ROOT/tcl/check_project.tcl" -tclargs "$XPR"

echo "PROJECT CHECK RESULT=PASS"
echo "No synthesis or implementation was launched"

