# Pre-publish checklist

- [x] Confirm no Vivado license, GitHub credential, private key, server address
      or personal absolute path is present.
- [x] Confirm no `.bit`, `.dcp`, generated Vivado project or generated IP output
      is staged in Git.
- [x] Run `bash -n scripts/*.sh`.
- [x] Reproduce `01-apply-board-adaptation.sh` in a clean recursive clone.
- [x] Run RTL generation, source audit and project audit without synthesis.
