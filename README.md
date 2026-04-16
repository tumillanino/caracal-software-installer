# Caracal Software Installer

`caracal-software-installer` is a Go TUI built with `tview` for guided post-install setup on Caracal OS. It presents optional DAWs, instruments, plugins, and audio utilities in browsable categories and lets the user queue multiple installs in one pass.

## Current catalog

- DAWs
  - REAPER
  - Renoise
  - Bitwig Studio
- Virtual Instruments
  - Warmplace
    - SunVox
    - Virtual ANS
    - Fractal Bits (cataloged; upstream desktop download is purchase-gated)
  - TAL
    - TAL-Noisemaker
  - Cardinal
  - Surge XT
  - Decent Sampler
- Effects
  - Audio Assault section placeholder
  - TAL effects section placeholder
- Utilities
  - RTCQS

The UI is catalog-driven, so adding more packages later is mostly a matter of dropping in scripts and extending the metadata in `internal/catalog`.

## Development

```bash
go mod tidy
go run ./cmd/caracal-software-installer
```

The app looks for installer scripts in:

1. `CARACAL_INSTALLER_SCRIPT_DIR`
2. `/usr/lib/caracal-software-installer/scripts`
3. `scripts/` in the current repo or a parent directory

Most package installs write to `/opt`, `/usr/local`, or the current user's home directory so they work on an atomic Caracal system without rpm layering.
