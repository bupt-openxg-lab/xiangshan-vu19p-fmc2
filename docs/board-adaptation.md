# Board adaptation details

The directory `board/pd-vu19p-solo-fmc2/overlay` mirrors paths relative to the
frozen upstream `env-scripts` repository. The preparation script copies only
these files into the user's disposable upstream source tree.

## Replaced upstream files

```text
fpga_diff/Makefile
fpga_diff/src/constr/common/ddr.xdc
fpga_diff/src/constr/common/fpga.xdc
fpga_diff/src/tcl/common/jtag_ddr_subsys.tcl
fpga_diff/src/tcl/common/xs_uart.tcl
fpga_diff/tools/gen_bitstream.tcl
```

## Added files

```text
fpga_diff/src/memory_parts/ksm26ses8_16hc_noecc.csv
fpga_diff/tools/limit_synth_threads.tcl
```

The overlaid `gen_bitstream.tcl` preserves the upstream run flow and adds a
final `impl_1` status check. A run is successful only when Vivado reports
`write_bitstream Complete`; a failed implementation cannot fall through to a
misleading success message.

## Generated RTL adjustment

`patches/generated-rtl/ClockGate.sv` replaces only the generated
`XiangShan/build/rtl/ClockGate.sv` after RTL elaboration. Under `SYNTHESIS` it
sets `Q = CK`; simulation retains the original latch-and-AND clock gate. This
avoids the large FPGA hold-time failure previously caused by ASIC-style gated
clock structures.

## No-Diff boundary

The baseline uses upstream `NO_DIFF=1`. The Vivado project contains standalone
`XSTop`, DDR/MIG, JTAG AXI, UART and reset logic. It omits the DiffTest endpoint,
PCIe IP, XDMA IP, PCIe constraints and DMA `data_bridge`. The unused XSTop DMA
AXI slave interface is tied off by the standalone wrapper.
