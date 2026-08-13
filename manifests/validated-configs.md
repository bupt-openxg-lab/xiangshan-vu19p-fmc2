# Validation matrix

The release installation and static project flow were reproduced from a clean
clone on 2026-08-13. See
[`installation-validation-20260813.md`](installation-validation-20260813.md).

| Configuration | Implementation | Bitstream | Programmed | DDR | Scalar | RVV | XVBBP EXT |
|---|---|---|---|---|---|---|---|
| micro2025 Minimal FMC2 | PASS | PASS | PASS | PASS | PASS | PASS | Not tested |
| XVBBP Minimal true No-Diff FMC2 | PASS | PASS | Pending | Pending | Pending | Pending | Pending |
| minjie Default physical No-Diff FMC2 | PASS | PASS | Pending | Pending | Pending | Pending | Not included |
| XVBBP Default physical No-Diff FMC2 | PASS | PASS | Pending | Pending | Pending | Pending | Pending |

## Default No-Diff implementation result

| Metric | Result |
|---|---:|
| CLB LUTs | 2,312,092 / 4,085,760 (56.59%) |
| CLB Registers | 877,334 / 8,171,520 (10.74%) |
| CLB sites | 419,904 / 510,720 (82.22%) |
| Block RAM Tile | 1,419.5 / 2,160 (65.72%) |
| WNS | +0.495 ns |
| TNS | 0.000 ns |
| WHS | +0.010 ns |
| THS | 0.000 ns |
| Routing errors | 0 |
| DRC errors | 0 |
| Full build wall time | approximately 6 h 54 min |

SLR1 reached 95.58% CLB-site utilization.

## XVBBP Default implementation result

| Metric | Result |
|---|---:|
| CLB LUTs | 2,872,428 / 4,085,760 (70.30%) |
| CLB Registers | 1,054,458 / 8,171,520 (12.90%) |
| Block RAM Tile | 1,523.5 / 2,160 (70.53%) |
| URAM | 32 / 320 (10.00%) |
| WNS | +0.538 ns |
| TNS | 0.000 ns |
| WHS | +0.001 ns |
| THS | 0.000 ns |
| Routing errors | 0 |
| DRC errors | 0 |

The +1 ps hold margin is the narrowest timing margin in this implementation.
