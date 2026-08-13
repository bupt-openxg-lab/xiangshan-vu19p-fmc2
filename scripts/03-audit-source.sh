#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

clockgate="$CORE_DIR/rtl/ClockGate.sv"
[[ -s "$clockgate" ]] || { echo "ERROR: missing $clockgate" >&2; exit 2; }
grep -Eq '^`ifdef SYNTHESIS$' "$clockgate"
grep -Eq '^[[:space:]]*assign Q = CK;$' "$clockgate"
grep -Eq '^[[:space:]]*assign Q = CK & EN;$' "$clockgate"

[[ -s "$FPGA_DIR/src/memory_parts/ksm26ses8_16hc_noecc.csv" ]]
rg -q 'KSM26SES8_16HC_NOECC_1600' "$FPGA_DIR/src/memory_parts/ksm26ses8_16hc_noecc.csv"
rg -q '200' "$FPGA_DIR/src/tcl/common/jtag_ddr_subsys.tcl"
rg -q '25' "$FPGA_DIR/src/tcl/common/xs_uart.tcl"

if rg -q 'GatewayEndpoint|axis_data_packge' "$CORE_DIR/rtl"; then
  echo "ERROR: DiffTest output-chain module found in generated RTL" >&2
  exit 3
fi

echo "SOURCE AUDIT RESULT=PASS"
echo "ClockGate bypass, DDR part and physical No-Diff RTL checks passed"

