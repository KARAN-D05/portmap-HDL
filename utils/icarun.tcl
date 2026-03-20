#!/usr/bin/env tclsh
# ============================================================
#  icarun.tcl  --  Icarus Verilog Automation Tool
#
#  Compiles and simulates a Verilog file with Icarus, prints
#  all $monitor/$display output, then optionally opens the
#  resulting VCD file in GTKWave.
#
#  Usage:
#    tclsh irun.tcl             -- interactive file picker
#    tclsh irun.tcl chip_tb.v   -- run directly
# ============================================================


proc colour {code text} { return "\033\[${code}m${text}\033\[0m" }

proc bold   {t} { colour "1"  $t }
proc green  {t} { colour "32" $t }
proc yellow {t} { colour "33" $t }
proc red    {t} { colour "31" $t }
proc cyan   {t} { colour "36" $t }
proc dim    {t} { colour "2"  $t }

proc sep {} { puts [dim "----------------------------------------------------"] }

proc banner {text} {
    sep
    puts "  [bold [cyan $text]]"
    sep
}

proc ask {prompt} {
    puts -nonewline $prompt
    flush stdout
    return [string trim [gets stdin]]
}

proc ask_yn {prompt} {
    set ans [ask "$prompt \[y/n\]: "]
    return [expr {[string tolower $ans] eq "y"}]
}

proc require_tool {name} {
    if {[auto_execok $name] eq ""} {
        puts [red "  ERROR: '$name' not found on PATH. Is it installed?"]
        exit 1
    }
}

proc find_vcd {src_file} {
    set fh [open $src_file r]
    set content [read $fh]
    close $fh

    if {[regexp {\$dumpfile\s*\(\s*"([^"]+\.vcd)"} $content _ vcdname]} {
        if {[file exists $vcdname]} { return $vcdname }
    }

    set vcds [lsort -decreasing -command {
        apply {{a b} {
            expr {[file mtime $a] - [file mtime $b]}
        }}
    } [glob -nocomplain *.vcd]]

    if {[llength $vcds] == 0} { return "" }

    return [lindex $vcds 0]
}

proc has_dump {src_file} {
    set fh [open $src_file r]
    set content [read $fh]
    close $fh
    return [regexp {\$dump(file|vars|on|off)} $content]
}

proc has_output {src_file} {
    set fh [open $src_file r]
    set content [read $fh]
    close $fh
    return [regexp {\$(monitor|display|write|strobe)} $content]
}

proc pick_verilog_file {} {
    set files [glob -nocomplain *.v]

    if {[llength $files] == 0} {
        puts [red "  No .v files found in current directory."]
        exit 1
    }

    puts ""
    puts [bold "  Verilog files in current directory:"]
    sep

    set i 1
    foreach f $files {
        puts "  [bold $i]  $f"
        incr i
    }
    sep

    set choice [ask "  Pick a file (number): "]

    if {$choice eq "" || ![string is integer -strict $choice] || $choice < 1 || $choice > [llength $files]} {
        puts [red "  Invalid choice."]
        exit 1
    }

    return [lindex $files [expr {$choice - 1}]]
}

proc open_gtkwave {vcd_file} {

    if {$vcd_file eq ""} {
        puts [yellow "  No VCD file found. Did your TB call \$dumpfile and \$dumpvars?"]
        return
    }

    puts ""
    puts [cyan "  VCD file: [bold $vcd_file]"]

    if {![ask_yn "  Open in GTKWave?"]} {
        puts [dim "  Skipped GTKWave."]
        return
    }

    global tcl_platform

    if {$tcl_platform(os) eq "Windows NT"} {
        set gtkwave_exe ""
        foreach candidate {
            "C:/Program Files/GTKWave/gtkwave.exe"
            "C:/gtkwave64/bin/gtkwave.exe"
            "C:/gtkwave/bin/gtkwave.exe"
        } {
            if {[file exists $candidate]} {
                set gtkwave_exe $candidate
                break
            }
        }

        if {$gtkwave_exe eq ""} {
            set gtkwave_exe "gtkwave"
        }

        puts [dim "  Launching: $gtkwave_exe $vcd_file"]
        exec cmd /c start "" "$gtkwave_exe" "$vcd_file" &

    } else {
        exec sh -c "gtkwave \"$vcd_file\" &"
    }

    puts [green "  GTKWave launched."]
}

if {$argc == 0} {
    set src [pick_verilog_file]
} elseif {$argc == 1} {
    set src [lindex $argv 0]
} else {
    puts [red "Usage: tclsh irun.tcl \[testbench.v\]"]
    exit 1
}

if {![file exists $src]} {
    puts [red "  File not found: $src"]
    exit 1
}

set base [file rootname [file tail $src]]
set vvp  "${base}.vvp"

banner "IRUN -- Icarus Verilog Runner"
puts "  Source  : [bold $src]"
puts "  Output  : [bold $vvp]"
sep

require_tool iverilog
require_tool vvp

set has_out  [has_output $src]
set has_dump [has_dump   $src]

if {$has_out}  { puts [green "  \$monitor/\$display detected -- will show output"] }
if {$has_dump} { puts [green "  \$dumpfile detected   -- VCD will be generated"]  }

if {!$has_out && !$has_dump} {
    puts [yellow "  Warning: no \$monitor, \$display, or \$dumpfile found in source"]
}
sep

puts ""
puts [bold "  \[1/2\] Compiling..."]
puts [dim  "  iverilog -o $vvp $src"]
puts ""

set compile_result [catch {exec iverilog -o $vvp $src} compile_out]

if {$compile_result != 0} {
    puts [red "  COMPILE FAILED"]
    sep
    puts $compile_out
    sep
    exit 1
}

if {$compile_out ne ""} { puts $compile_out }
puts [green "  Compiled OK -> $vvp"]

puts ""
puts [bold "  \[2/2\] Simulating..."]
puts [dim  "  vvp $vvp"]
sep
puts ""

set sim_result [catch {exec vvp $vvp} sim_out]

if {$sim_out ne ""} { puts $sim_out }
puts ""
sep

if {$sim_result != 0} {
    if {[string match "*$finish called*" $sim_out] || [string match "*End of simulation*" $sim_out]} {
        puts [green "  Simulation finished (\$finish called)."]
    } else {
        puts [yellow "  Simulation exited with warnings (shown above)."]
    }
} else {
    puts [green "  Simulation complete."]
}

if {$has_dump} {
    puts ""
    set vcd [find_vcd $src]
    open_gtkwave $vcd
} else {
    puts ""
    puts [dim "  No VCD dump in source -- GTKWave step skipped."]
    puts [dim "  Add these lines to your TB to enable waveform viewing:"]
    puts [dim "    initial begin \$dumpfile(\"${base}.vcd\"); \$dumpvars(0, ${base}); end"]
}

sep
puts [dim "  Done."]
puts ""
