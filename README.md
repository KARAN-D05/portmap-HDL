# 🔌portmap-hdl

A lightweight CLI tool to extract and display port definitions from Verilog files.

## ⚙️ What it does

Point it at any Verilog file and it instantly prints a clean, aligned table of all ports - name, direction, and bus width. Useful for quickly inspecting unfamiliar modules or documenting your own.

<p align="center">
  <img src="images/port-extraction-default.png"  width="500"/>
  <br>
  <sub>Port-Extraction (Default)</sub>
</p>

<p align="center">
  <img src="images/port-extraction-markdown.png"  width="1000"/>
  <br>
  <sub>Port-Extraction (Markdown )</sub>
</p>

## ✨ Features
- Extracts `input`, `output`, and `inout` ports
- Detects bus widths (e.g. `[7:0]`)
- Clean, aligned CLI table output
- Markdown export with `--md` flag

## 🛠️ Usage
```
portmap file.v
```

For Markdown output:
```
portmap file.v --md
```

## 📦 Install

### 🐧 Linux
Download `portmap-linux-x64` from the [latest release](https://github.com/KARAN-D05/portmap-HDL/releases/tag/v1.0.0), then:
```bash
chmod +x portmap-linux-x64
sudo mv portmap-linux-x64 /usr/local/bin/portmap
```

### 🪟 Windows
Download `portmap-windows-x64.exe` from the [latest release](https://github.com/KARAN-D05/portmap-HDL/releases/tag/v1.0.0), then open PowerShell and run:
```powershell
cd "$env:USERPROFILE\Downloads"
move portmap-windows-x64.exe "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\portmap.exe"
```

## 🏗️ Build from source

Requires [Nim](https://nim-lang.org/install.html).
```
nim c -d:release -o:portmap portmap.nim
```

## 📝 Notes
- Testbench files may show no ports (expected behavior)
- Designed for standard Verilog module definitions

## 🧪 Tests

Download test files from [Tests folder](tests) → Provide 4 test files
```
portmap tests/det.v       # Default version
portmap tests/det.v --md  # Markdown Version

Compare with images in readme for det.v.
```

## ⬇️ Download This Repository

### 🪟 Windows
Download → [download_repos.bat](./download_repos.bat)
``` 
Double-click it and pick the repo(s) you want.
```

### 🐧 Linux / macOS
Download → [download_repos.sh](./download_repos.sh)
```
bash

chmod +x download_repos.sh
./download_repos.sh
```

> Always downloads the latest version.
