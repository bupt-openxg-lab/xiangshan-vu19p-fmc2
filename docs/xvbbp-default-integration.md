# XVBBP Default integration

This board repository does not copy or own the XVBBP CPU source. The frozen
CPU/instruction/workload tuple is maintained in
[`bupt-openxg-lab/riscv-xvbbp`](https://github.com/bupt-openxg-lab/riscv-xvbbp)
and originates from `GaryCAICHI/xs-env` branch `kunminghu-v2-xvbbp`.

## Validated source tuple

| Component | Revision |
|---|---|
| xs-env | `c01a7268adc55b901ea251f43e28b94fb220e443` |
| XiangShan | `e34d8adbaf7cd890a7b148c1e9622d38435996b1` |
| YunSuan | `b4a62448b1539ab875daf36a62fe9cf6bc2fbe7b` |
| nexus-am | `9dc5f1e19b3e0dc58beade6f9a2e25dc90a6f2b8` |

Do not mix these revisions with an arbitrary XiangShan or YunSuan checkout.

## RTL configuration

The validated generation used:

```text
CONFIG=FpgaDefaultConfig
RELEASE=1
--disable-always-basic-diff
--disable-perf
--disable-alwaysdb
```

The resulting CPU top is standalone `XSTop`; `SimTop`, `GatewayEndpoint` and
the physical DiffTest/PCIe/XDMA output chain must be absent from the Vivado
source set. Apply the same synthesis-only `ClockGate` bypass documented in
[board-adaptation.md](board-adaptation.md).

## Sequential-memory extraction

The frozen fork can emit a monolithic `array_1024x8160.sv`. Vivado 2020.2
cannot elaborate that variable, so a plain `make verilog` result is not a valid
FPGA input even if `XSTop.fir` was generated.

Regenerate SystemVerilog from that FIR with the matching firtool options:

```text
--split-verilog
--repl-seq-mem
--repl-seq-mem-file=<rtl-output>/XSTop.sv.conf
```

Then run the XiangShan `gen_sep_mem.sh`/`vlsi_mem_gen` flow against
`XSTop.sv.conf`. The validated result contained 33 external SRAM
implementations. Before creating the Vivado project, verify all of the
following:

- `XSTop.sv` and `XSTop.sv.conf` exist;
- at least one generated `*_ext.v` memory module exists;
- no `module array_1024x8160` remains;
- only the active `build/rtl` directory is added to the project;
- old or failed RTL backup directories are outside the Vivado source set.

This memory-replacement step changes representation, not the seven XVBBP
instruction semantics.

## Board assembly and result

Use the board overlay from this repository after producing the audited RTL.
Generate the project with physical `NO_DIFF=1`, FMC2 DDR, JTAG AXI and UART.
The validated XVBBP Default implementation used Vivado 2020.2 and completed
bitstream generation with the resource/timing result recorded in
[../manifests/validated-configs.md](../manifests/validated-configs.md).

Bitstream completion is not an on-board instruction test. Physical validation
still requires DDR calibration, JTAG workload loading, CPU reset/release and
UART observation of the scalar/RVV/EXT test results.
