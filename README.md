# XiangShan on PD-VU19P Solo with FMC2 DDR4

This repository provides the board adaptation for running a physical No-Diff
XiangShan FPGA design on the Phine Design PD-VU19P-2-LSI Solo v3 with the
UV-FMCH-PDDR4DME DDR4 daughter card installed at FMC2.

## Features

- FMC2 DDR4 pin constraints and MIG configuration.
- 16 GiB single-rank x64 DDR4-1600 support.
- Independent 200 MHz DDR reference and 25 MHz CPU/SoC input clocks.
- JTAG AXI workload loading and UART program output.
- Physical No-Diff project without DiffTest, PCIe or XDMA.
- Congestion-oriented Vivado synthesis and implementation settings.
- Automated source preparation, project checks, builds and report collection.

## Supported Configuration

| Item | Configuration |
|---|---|
| FPGA | `xcvu19p-fsva3824-2-e` |
| Board | PD-VU19P-2-LSI Solo v3 |
| DDR card | UV-FMCH-PDDR4DME at FMC2 |
| DDR | 16 GiB, single rank, x64 |
| MIG | DDR4-1600 |
| DDR reference clock | 200 MHz differential |
| CPU/SoC input clock | 25 MHz |
| CPU configuration | `FpgaDefaultConfig` |
| FPGA mode | Physical `NO_DIFF=1` |
| Workload loading | JTAG AXI to DDR |
| Program output | UART |
| Vivado | 2020.2 |

The board layer has been implemented with both the frozen upstream minjie
`FpgaDefaultConfig` and the XVBBP `FpgaDefaultConfig`. XVBBP integration is
described in [docs/xvbbp-default-integration.md](docs/xvbbp-default-integration.md).

## Project Structure

```text
board/pd-vu19p-solo-fmc2/  board constraints and Vivado project overlay
scripts/                    preparation, audit, build and status scripts
tcl/                        Vivado checks, reports and implementation helpers
docs/                       board, clock, JTAG and UART documentation
manifests/                  source versions and validated configurations
```

## Requirements

- Linux, Bash, Git and GNU Make.
- Vivado 2020.2 with a VU19P-capable license.
- At least 90 GiB RAM and 60 GiB free disk for the reference build.
- A recursive minjie-playground source tree at the revisions listed in
  [manifests/upstream-versions.md](manifests/upstream-versions.md).

Prepare the source tree with:

```bash
git clone --recursive https://github.com/OpenXiangShan/minjie-playground.git
cd minjie-playground
git checkout 62f6cd8f6e7f9a3c3846b8f526a42973a839522f
git submodule update --init --recursive
```

Vitis is not required.

## Prepare the Project

```bash
cp config.env.example config.env
$EDITOR config.env

./scripts/00-preflight.sh
./scripts/01-apply-board-adaptation.sh
./scripts/02-generate-rtl.sh
./scripts/03-audit-source.sh
./scripts/04-generate-and-check-project.sh
```

## Build the Bitstream

Run the complete build in the current terminal:

```bash
./scripts/10-build.sh
```

Or run it in a GNU screen session:

```bash
./scripts/11-start-build-screen.sh
./scripts/20-status.sh
tail -f logs/latest-build.log
```

A successful build reports:

```text
route_design completed successfully
All user specified timing constraints are met
write_bitstream completed successfully
BUILD RESULT=PASS
```

The bitstream, debug probes, checkpoints and reports are collected under
`artifacts/`.

## Program and Run

1. Configure platform power and clocks with AEConsole.
2. Set the DDR reference to 200 MHz and CPU/SoC input to 25 MHz.
3. Program the `.bit` and `.ltx` files with Vivado Hardware Manager.
4. Confirm DDR MIG calibration.
5. Load the bare-metal image into DDR through JTAG AXI.
6. Release the CPU reset and monitor UART output.

Detailed operations are documented in
[docs/jtag-uart-workflow.md](docs/jtag-uart-workflow.md).

## Validation Results

The reference `FpgaDefaultConfig` No-Diff design passed synthesis, placement,
routing, timing, DRC and bitstream generation with Vivado 2020.2. The validated
XVBBP Default build used 70.30% LUT and 70.53% BRAM Tile, with WNS `+0.538 ns`,
WHS `+0.001 ns` and zero routing or DRC errors.

The release scripts were also verified from a clean recursive clone on
2026-08-13. Board installation, RTL generation, source audit, Vivado project
generation and project audit all passed without starting synthesis or
implementation.

See [manifests/validated-configs.md](manifests/validated-configs.md) for complete
build records.

## Source and License

See [NOTICE](NOTICE), [LICENSE](LICENSE) and
[manifests/upstream-versions.md](manifests/upstream-versions.md).
