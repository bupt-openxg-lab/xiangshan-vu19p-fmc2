#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

mkdir -p "$LOG_DIR"
stamp=$(date +%Y%m%d-%H%M%S)
rtl_log="$LOG_DIR/rtl-$stamp.log"
ln -sfn "$(basename "$rtl_log")" "$LOG_DIR/latest-rtl.log"

make -C "$SOURCE_ROOT" verilog xiangshan \
  NO_DIFF=1 XS_CONFIG=FpgaDefaultConfig \
  XS_DEBUG_ARGS=--disable-always-basic-diff JOBS="$RTL_JOBS" \
  2>&1 | tee "$rtl_log"

clockgate="$CORE_DIR/rtl/ClockGate.sv"
[[ -s "$clockgate" ]] || { echo "ERROR: generated ClockGate.sv not found" >&2; exit 3; }
cp "$RELEASE_ROOT/patches/generated-rtl/ClockGate.sv" "$clockgate"

echo "RTL GENERATION RESULT=PASS"
echo "RTL: $CORE_DIR/rtl"
echo "Log: $rtl_log"

