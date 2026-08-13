# Frozen upstream revisions

| Component | Repository | Revision |
|---|---|---|
| minjie-playground | `https://github.com/OpenXiangShan/minjie-playground` | `62f6cd8f6e7f9a3c3846b8f526a42973a839522f` |
| XiangShan | `https://github.com/OpenXiangShan/XiangShan` | `3fdbebedf6d505dedfdd66f8d8154c82136963a6` |
| env-scripts | `https://github.com/OpenXiangShan/env-scripts` | `50117ce4366c97699f1b5fe3eed2ec8b5968d3d6` |
| difftest | `https://github.com/OpenXiangShan/difftest` | `36062fbd54579220e8aff92bc820e2fd3e749539` |

The difftest source is used while elaborating RTL. The final physical No-Diff
Vivado project does not instantiate the DiffTest endpoint, PCIe, XDMA or
`data_bridge`.

## RTL configuration

```text
FpgaDefaultConfig
--disable-always-basic-diff
--fpga-platform
--disable-all
--remove-assert
--disable-clockgate
```

Generated CPU top: `XSTop`.

