# Clean installation validation — 2026-08-13

## Environment

| Item | Value |
|---|---|
| Host OS | Ubuntu Linux |
| Vivado | 2020.2 |
| RAM | 125 GiB |
| Source | Clean recursive minjie-playground clone |
| minjie-playground | `62f6cd8f6e7f9a3c3846b8f526a42973a839522f` |
| XiangShan | `3fdbebedf6d505dedfdd66f8d8154c82136963a6` |
| env-scripts | `50117ce4366c97699f1b5fe3eed2ec8b5968d3d6` |
| difftest | `36062fbd54579220e8aff92bc820e2fd3e749539` |

## Results

| Stage | Result |
|---|---|
| `00-preflight.sh` | PASS |
| `01-apply-board-adaptation.sh` | PASS |
| Overlay-to-installed file comparison | PASS, 8/8 files identical |
| Core board files compared with successful Default FMC2 build | PASS, 5/5 files identical |
| `02-generate-rtl.sh` | PASS |
| `03-audit-source.sh` | PASS |
| `04-generate-and-check-project.sh` | PASS |
| Synthesis run status | Not started |
| Implementation run status | Not started |

The five core board files compared with the successful implementation were
`Makefile`, `ddr.xdc`, `fpga.xdc`, `jtag_ddr_subsys.tcl` and `xs_uart.tcl`.

## Project audit summary

- Device: `xcvu19p-fsva3824-2-e`.
- Top: `fpga_top_debug` with one standalone `XSTop` source.
- Physical `NO_DIFF=1`; no GatewayEndpoint, XDMA block design, PCIe constraints
  or `data_bridge` block design.
- DDR: custom `KSM26SES8_16HC_NOECC_1600`, x64, 34-bit AXI address, ECC off.
- DDR input: 200 MHz; SoC input: 25 MHz.
- JTAG AXI: 64-bit address and 64-bit data.
- Synthesis strategy: `Flow_PerfOptimized_high`.
- Implementation strategy: `Congestion_SSI_SpreadLogic_high`.

## Environment compatibility fixes

The validation added two Vivado 2020.2 startup improvements to `scripts/lib.sh`:

- prefer `.settings64-Vivado.sh` so a Vivado-only installation does not depend
  on Vitis HLS;
- add Vivado's bundled `libtinfo.so.5` directory to `LD_LIBRARY_PATH` on newer
  Ubuntu systems.

Both changes use files supplied by the Vivado installation and require no
system-library replacement.
