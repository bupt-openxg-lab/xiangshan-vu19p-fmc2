# Hardware configuration

| Item | Value |
|---|---|
| Platform | Phine Design PD-VU19P-2-LSI Solo v3 |
| Device | `xcvu19p-fsva3824-2-e` |
| Daughter card | UV-FMCH-PDDR4DME at FMC2 |
| DIMM model used by MIG | `KSM26SES8_16HC_NOECC_1600` |
| Capacity | 16 GiB |
| Organization | Single rank, x64 data, x8 components |
| ECC | Disabled; the eight ECC data lanes are not used |
| DDR rate | DDR4-1600 |
| DDR reference clock | 200 MHz differential |
| CPU/SoC board clock | 25 MHz |
| Image loading | JTAG AXI, 64-bit path |
| Console | UART |
| PCIe daughter card | Not required by this physical No-Diff baseline |

The 200 MHz signal is the MIG reference input. It does not require the CPU to
run at 200 MHz; the CPU input clock is independently configured to 25 MHz.

Clock-name clarification:

- `clk5`/`DEBUG_CLK_IN` is the physical 25 MHz clock connected to
  `XSTop.io_clock` through `dbg_clk_buf`;
- `clk6` has the legacy timing name `CPU_CLK_IN` and a 200 MHz constraint, but
  feeds `cqetmclk`, not the CPU execution clock;
- `clk7_p` is the DDR daughter-card 200 MHz differential reference input.
