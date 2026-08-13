# Troubleshooting

## Vivado version is reported as unknown

Vivado 2020.2 may print an empty line before `Vivado v2020.2`. The adapted
Makefile searches for the first line beginning with `Vivado v` instead of
assuming the first output line contains the version.

## Synthesis succeeds but implementation reports large hold violations

Audit the generated `ClockGate.sv` with `scripts/03-audit-source.sh`. ASIC-style
latch-and-AND clock gating previously created large skew and hundreds of
thousands of hold failures on VU19P.

## Project contains XDMA or PCIe

Confirm the project was generated with `NO_DIFF=1`. The audit Tcl rejects a
project that does not match the expected physical No-Diff structure.

## No-Diff log mentions missing PCIe or DiffTest objects

The frozen `fpga.xdc` retains several historical PCIe/refclk/DiffTest clock
commands. In a physical No-Diff project those objects are absent, so Vivado can
print missing-object constraint warnings even though XDMA/PCIe logic is not in
the project. Confirm this with `tcl/check_project.tcl`: `xdma_ep.bd` and
`data_bridge.bd` must both have count zero. These warnings were present in the
successful reference builds.

The release intentionally preserves the successfully implemented XDC instead
of silently changing its constraints. If the warnings are later guarded with
object-existence checks, rerun project audit and full timing/DRC validation
before treating the modified XDC as a new validated baseline.

## DDR calibration fails on board

Check the FMC2 installation, DIMM model, single-rank/x64 MIG parameters, 200 MHz
differential reference, reset polarity and the exact `.bit`/`.ltx` pair. A
successful route and bitstream do not prove physical DDR calibration.

## Build appears idle

Use `scripts/20-status.sh`, inspect `logs/latest-build.log`, attach to the named
GNU screen session and inspect the Vivado run logs. Do not interrupt a run only
because the top-level log is temporarily quiet.
