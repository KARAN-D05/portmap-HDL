# 🧰 Utils
- Handy companion command line tools automatically fetched along my projects dowloads through [download_repos.sh](../download_repos.sh) for linux or [download_repos.bat](../download_repos.bat) for windows.
- Includes a verilog file port extractor and repo filetree visualizer.

## 🌳 Filetree
A repository file tree generator written in Lua. Prints a visual directory tree with file-type icons and a breakdown of key file counts at the bottom.

```
📁 8-Bit-Computer/
├── 📁 ALU
│   ├── 📄 8Bit_ALU_GI.circ
│   └── 📝 Readme.md
├── 📁 CLOCK
│   ├── 📁 CLOCK-Verilog
│   │   ├── 📄 A_clk.v
│   │   └── 📄 A_clk_tb.v
│   └── 📝 Readme.md
├── 🖥️ download_repos.bat
├── 🌙 filetree.lua
└── 📝 README.md

37 directories, 96 files
(.v: 9  .circ: 13  .md: 12  .bat: 1  .sh: 1)
```

### Requirements

| Platform | Requirement |
|----------|-------------|
| Linux / WSL | `sudo apt install lua5.4` |
| Windows | `scoop install lua` |

### Usage

```bash
# Current directory
lua filetree.lua 

# Specific directory
lua filetree.lua /path/to/repo

# Limit depth
lua filetree.lua --depth 2

# Output wrapped in markdown code fence (for pasting into READMEs)
lua filetree.lua --md

# Help
lua filetree.lua --help
```

On Linux/WSL you may need `lua5.4` instead of `lua` depending on your install.

### Windows (PowerShell)

Enable UTF-8 once so emojis and tree characters render correctly:

```powershell
chcp 65001
$OutputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
```

To make this permanent, add those two lines to your PowerShell profile:

```powershell
notepad $PROFILE
```

Then run normally:

```powershell
lua filetree.lua .
```

### Icons

| Icon | Extensions |
|------|-----------|
| 📁 | Directory |
| 📄 | `.v` `.sv` `.vh` `.svh` |
| 🐍 | `.py` |
| ⚙️ | `.c` `.h` `.cpp` |
| 📝 | `.md` `.txt` |
| 🖥️ | `.sh` `.bat` |
| 📋 | `.json` `.yml` `.yaml` |
| 📌 | `.xdc` `.sdc` |
| 🔧 | `.tcl` |
| 🌙 | `.lua` |
| 👑 | `.nim` |

### Footer breakdown

Tracks counts for: `.v` `.circ` `.md` `.py` `.c` `.bat` `.sh` `.ps1` - only shows extensions with at least one file.

## 🔌portmap
A lightweight CLI tool to extract port definitions from Verilog files.

### Features
- Extracts `input`, `output`, and `inout` ports
- Detects bus widths (e.g. `[7:0]`)
- Clean, aligned CLI table output
- Markdown export with `--md` flag

### Usage
#### Pretty table (default)
```bash
portmap file.v
```
#### Markdown output
```bash
portmap file.v --md
```

### Install (Linux)
Download the binary from [portmap folder](portmap), then:
```bash
chmod +x portmap-linux-x64
sudo mv portmap-linux-x64 /usr/local/bin/portmap
```
Now you can run:
```bash
portmap file.v
```

### Install (Windows)
Download `portmap-windows-x64.exe` from [portmap folder](portmap), then open PowerShell and run:
```powershell
move portmap-windows-x64.exe "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\portmap.exe"
```
Now you can run:
```powershell
portmap file.v
```

### Notes
- Testbench files may show no ports (expected behavior)
- Designed for standard Verilog module definitions

### Build from source
```bash
nim c -d:release portmap.nim
```

## GitHub 
```
https://github.com/KARAN-D05
```
