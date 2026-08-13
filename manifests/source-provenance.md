# Source provenance

This release directory was assembled from the successful local adaptation and
reference build completed on 2026-08-09.

Compatibility was subsequently confirmed by the successful 2026-08-10 XVBBP
`FpgaDefaultConfig` implementation. The five core FMC2 board files in that
build (`Makefile`, `ddr.xdc`, `fpga.xdc`, `jtag_ddr_subsys.tcl` and
`xs_uart.tcl`) were SHA-256 identical to this release overlay. The later run
therefore extends the validated CPU-source coverage without changing the FMC2
pin map or MIG configuration.

| Release content | Reference build | Purpose |
|---|---|---|
| Board overlay | Default No-Diff FMC2 implementation | FMC2 constraints, MIG, clocks, UART and build settings |
| ClockGate replacement | Generated XiangShan RTL | Synthesis clock-gate implementation |
| Vivado audit/report Tcl | Default No-Diff FMC2 implementation | Project checks and report export |
| Reference reports | 2026-08-09 implementation | Resource, timing and DRC results |
