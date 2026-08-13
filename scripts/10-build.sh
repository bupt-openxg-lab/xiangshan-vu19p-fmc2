#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

[[ -f "$XPR" ]] || { echo "ERROR: run 04-generate-and-check-project.sh first" >&2; exit 3; }
stamp=$(date +%Y%m%d-%H%M%S)
build_log="$LOG_DIR/build-$stamp.log"
ln -sfn "$(basename "$build_log")" "$LOG_DIR/latest-build.log"

{
  echo "===== FULL BUILD START $(date '+%F %T') ====="
  make -C "$FPGA_DIR" bitstream \
    CORE_DIR="$CORE_DIR" CPU=kmh SUFFIX=default-fmc2 \
    NO_DIFF=1 DDR_RANK_WIDTH=1 VIVADO_JOBS="$VIVADO_JOBS" \
    VIVADO_SYNTH_THREADS="$VIVADO_SYNTH_THREADS"
  echo "===== FULL BUILD PASS $(date '+%F %T') ====="
} 2>&1 | tee "$build_log"

vivado -mode batch -nojournal -nolog -notrace \
  -source "$RELEASE_ROOT/tcl/export_reports.tcl" \
  -tclargs "$XPR" "$REPORT_DIR"

find "$PRJ_DIR" -type f \( -name '*.bit' -o -name '*.ltx' \) \
  -exec cp -v {} "$ARTIFACT_DIR/" \;

echo "BUILD RESULT=PASS"
echo "Artifacts: $ARTIFACT_DIR"
echo "Log: $build_log"

