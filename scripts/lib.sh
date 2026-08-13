#!/usr/bin/env bash
set -Eeuo pipefail

RELEASE_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CONFIG_FILE=${CONFIG_FILE:-"$RELEASE_ROOT/config.env"}

load_config() {
  [[ -r "$CONFIG_FILE" ]] || {
    echo "ERROR: copy config.env.example to config.env and edit it" >&2
    exit 2
  }

  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  : "${VIVADO_SETTINGS:?Set VIVADO_SETTINGS in config.env}"
  : "${XILINXD_LICENSE_FILE:?Set XILINXD_LICENSE_FILE in config.env}"
  : "${SOURCE_ROOT:?Set SOURCE_ROOT in config.env}"
  : "${VIVADO_JOBS:=8}"
  : "${VIVADO_SYNTH_THREADS:=8}"
  : "${RTL_JOBS:=16}"
  : "${MIN_RAM_GIB:=90}"
  : "${MIN_DISK_GIB:=60}"

  SOURCE_ROOT=$(realpath -m "$SOURCE_ROOT")
  [[ -r "$VIVADO_SETTINGS" ]] || { echo "ERROR: unreadable Vivado settings" >&2; exit 2; }
  [[ -r "$XILINXD_LICENSE_FILE" ]] || { echo "ERROR: unreadable Vivado license" >&2; exit 2; }
  [[ -d "$SOURCE_ROOT/.git" ]] || { echo "ERROR: SOURCE_ROOT is not a minjie clone" >&2; exit 2; }

  # AMD's top-level settings64.sh may also source optional Vitis components.
  # This flow needs Vivado only, so prefer the Vivado-specific environment
  # script when it is present next to the configured wrapper.
  local vivado_only_settings
  vivado_only_settings="$(dirname "$VIVADO_SETTINGS")/.settings64-Vivado.sh"
  if [[ -r "$vivado_only_settings" ]]; then
    # shellcheck disable=SC1090
    source "$vivado_only_settings"
  else
    # shellcheck disable=SC1090
    source "$VIVADO_SETTINGS"
  fi

  # Vivado 2020.2 includes the ncurses5 compatibility library required on
  # newer Ubuntu releases. Use its private copy without changing system libs.
  local vivado_compat_lib
  vivado_compat_lib="$XILINX_VIVADO/lib/lnx64.o/SuSE"
  if [[ -r "$vivado_compat_lib/libtinfo.so.5" ]]; then
    export LD_LIBRARY_PATH="$vivado_compat_lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
  export XILINXD_LICENSE_FILE VIVADO_JOBS VIVADO_SYNTH_THREADS
}

project_paths() {
  XIANGSHAN_ROOT="$SOURCE_ROOT/XiangShan"
  ENV_SCRIPTS_ROOT="$SOURCE_ROOT/env-scripts"
  CORE_DIR="$XIANGSHAN_ROOT/build"
  FPGA_DIR="$ENV_SCRIPTS_ROOT/fpga_diff"
  PRJ_NAME=fpga_kmh-nodiff-default-fmc2
  PRJ_DIR="$FPGA_DIR/$PRJ_NAME"
  XPR="$PRJ_DIR/$PRJ_NAME.xpr"
  LOG_DIR="$RELEASE_ROOT/logs"
  ARTIFACT_DIR="$RELEASE_ROOT/artifacts"
  REPORT_DIR="$ARTIFACT_DIR/reports"
  mkdir -p "$LOG_DIR" "$ARTIFACT_DIR" "$REPORT_DIR"
}

assert_revision() {
  local repo=$1 expected=$2 label=$3 actual
  actual=$(git -C "$repo" rev-parse HEAD)
  [[ "$actual" == "$expected" ]] || {
    echo "ERROR: $label revision mismatch" >&2
    echo "  expected: $expected" >&2
    echo "  actual:   $actual" >&2
    exit 3
  }
}
