#!/bin/bash

# GTKWave waveform viewer script for Mealy FSM

VCD_FILE="build/tb_vending_machine_mealy.vcd"
GTKW_FILE="scripts/mealy_wave.gtkw"

if [ ! -f "$VCD_FILE" ]; then
    echo "Error: VCD file not found at $VCD_FILE"
    echo "Please run 'make sim-mealy' first to generate the waveform file."
    exit 1
fi

if command -v gtkwave &> /dev/null; then
    if [ -f "$GTKW_FILE" ]; then
        gtkwave "$VCD_FILE" "$GTKW_FILE"
    else
        gtkwave "$VCD_FILE"
    fi
else
    echo "Error: GTKWave is not installed."
    echo "Please install it using:"
    echo "  Ubuntu/Debian: sudo apt-get install gtkwave"
    echo "  macOS: brew install gtkwave"
    exit 1
fi
