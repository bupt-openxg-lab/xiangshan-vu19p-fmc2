#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

assert_revision "$SOURCE_ROOT" 62f6cd8f6e7f9a3c3846b8f526a42973a839522f minjie-playground
assert_revision "$ENV_SCRIPTS_ROOT" 50117ce4366c97699f1b5fe3eed2ec8b5968d3d6 env-scripts

overlay="$RELEASE_ROOT/board/pd-vu19p-solo-fmc2/overlay"
[[ -d "$overlay/fpga_diff" ]] || { echo "ERROR: missing board overlay" >&2; exit 2; }

cp -a "$overlay/fpga_diff/." "$FPGA_DIR/"

echo "BOARD ADAPTATION RESULT=PASS"
echo "Applied only the files listed in docs/board-adaptation.md"
echo "Target: $FPGA_DIR"

