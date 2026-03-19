# portmap-hdl

A lightweight CLI tool to extract and display port definitions from Verilog files.

## What it does

Point it at any Verilog file and it instantly prints a clean, aligned table of all ports - name, direction, and bus width. Useful for quickly inspecting unfamiliar modules or documenting your own.

## Features
- Extracts `input`, `output`, and `inout` ports
- Detects bus widths (e.g. `[7:0]`)
- Clean, aligned CLI table output
- Markdown export with `--md` flag

## Usage
```bash
portmap file.v
```

For Markdown output:
```bash
portmap file.v --md
```

## Install

### Linux
Download the binary from the [latest release](https://github.com/KARAN-D05/portmap-HDL/releases/tag/v1.0.0), then:
```bash
chmod +x portmap-linux-x64
sudo mv portmap-linux-x64 /usr/local/bin/portmap
```

### Windows
Download `portmap-windows-x64.exe` from the [latest release](https://github.com/KARAN-D05/portmap-HDL/releases/tag/v1.0.0), then open PowerShell and run:
```powershell
cd "$env:USERPROFILE\Downloads"
move portmap-windows-x64.exe "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\portmap.exe"
```

## Build from source

Requires [Nim](https://nim-lang.org/install.html).
```bash
nim c -d:release -o:portmap portmap.nim
```

## Notes
- Testbench files may show no ports (expected behavior)
- Designed for standard Verilog module definitions
