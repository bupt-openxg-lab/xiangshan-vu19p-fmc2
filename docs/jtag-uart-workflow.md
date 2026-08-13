# JTAG, DDR and UART workflow

## Connections

- Management Ethernet: AEConsole control only.
- JTAG: FPGA configuration, VIO/ILA access and JTAG AXI transactions.
- UART: bare-metal software output.
- FMC2: DDR4 daughter card.

## Order of operation

1. Check the daughter card and cables while the platform is safely powered down.
2. Start AEConsole and connect to the platform controller.
3. Configure the required board voltages and clocks.
4. Confirm the 200 MHz differential DDR reference and 25 MHz CPU input.
5. Program the FPGA with the generated `.bit`; associate the matching `.ltx`.
6. Refresh the hardware device and check that MIG, VIO, ILA and JTAG AXI cores
   are discovered as expected.
7. Check the MIG calibration indication before writing a workload to DDR.
8. Halt the SoC if required, write the binary through JTAG AXI, then reset and
   release the CPU.
9. Observe UART with the baud rate and framing required by the generated design.

Programming the FPGA does not automatically load the bare-metal workload.
Likewise, writing DDR does not automatically release the CPU reset.

The actual SoC/CPU path is `clk5 -> dbg_clk_buf -> XSTop` at 25 MHz. The
`CPU_CLK_IN` name shown for the separate 200 MHz `clk6` timing constraint is a
legacy name and is not the CPU execution clock.

## Current limitation

The archived minjie Default bitstream has passed implementation but has not yet
completed these physical-board runtime steps. Preserve this distinction in
reports and release notes.
