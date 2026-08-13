#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
load_config
project_paths

assert_revision "$SOURCE_ROOT" 62f6cd8f6e7f9a3c3846b8f526a42973a839522f minjie-playground
assert_revision "$XIANGSHAN_ROOT" 3fdbebedf6d505dedfdd66f8d8154c82136963a6 XiangShan
assert_revision "$ENV_SCRIPTS_ROOT" 50117ce4366c97699f1b5fe3eed2ec8b5968d3d6 env-scripts
assert_revision "$SOURCE_ROOT/difftest" 36062fbd54579220e8aff92bc820e2fd3e749539 difftest

command -v vivado >/dev/null || { echo "ERROR: vivado not found" >&2; exit 2; }
command -v rg >/dev/null || { echo "ERROR: ripgrep (rg) not found" >&2; exit 2; }
vivado_output=$(vivado -version 2>&1)
vivado_version=$(sed -n '/^Vivado v/{p;q}' <<<"$vivado_output")
[[ "$vivado_version" == *"v2020.2"* ]] || {
  echo "ERROR: exact Vivado 2020.2 is required: ${vivado_version:-missing}" >&2
  exit 2
}

ram_gib=$(awk '/MemTotal:/ {printf "%d", $2 / 1024 / 1024}' /proc/meminfo)
disk_gib=$(df -Pk "$RELEASE_ROOT" | awk 'NR == 2 {printf "%d", $4 / 1024 / 1024}')
((ram_gib >= MIN_RAM_GIB)) || { echo "ERROR: RAM ${ram_gib} GiB < ${MIN_RAM_GIB} GiB" >&2; exit 2; }
((disk_gib >= MIN_DISK_GIB)) || { echo "ERROR: disk ${disk_gib} GiB < ${MIN_DISK_GIB} GiB" >&2; exit 2; }

echo "Vivado: $vivado_version"
echo "Source: $SOURCE_ROOT"
echo "RAM: ${ram_gib} GiB"
echo "Free disk: ${disk_gib} GiB"
echo "PREFLIGHT RESULT=PASS"
