#!/bin/bash

# Simulation script for Vending Machine Controller
# This script runs simulations for both Mealy and Moore FSMs

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Icarus Verilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}Error: Icarus Verilog is not installed.${NC}"
    echo "Please install it using:"
    echo "  Ubuntu/Debian: sudo apt-get install iverilog"
    echo "  macOS: brew install icarus-verilog"
    exit 1
fi

# Create build directory
mkdir -p build

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Vending Machine Controller Simulation${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Function to run simulation
run_simulation() {
    local fsm_type=$1
    local src_file=$2
    local tb_file=$3
    local out_file=$4
    
    echo -e "${YELLOW}Compiling ${fsm_type} FSM...${NC}"
    iverilog -g2012 -Wall -o "$out_file" "$src_file" "$tb_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Compilation successful${NC}"
        echo ""
        echo -e "${YELLOW}Running ${fsm_type} FSM simulation...${NC}"
        vvp "$out_file"
        echo ""
        echo -e "${GREEN}✓ ${fsm_type} FSM simulation completed${NC}"
        echo ""
    else
        echo -e "${RED}✗ Compilation failed${NC}"
        exit 1
    fi
}

# Run Mealy FSM simulation
run_simulation "Mealy" "src/vending_machine_mealy.v" "tb/tb_vending_machine_mealy.v" "build/mealy_sim"

# Run Moore FSM simulation
run_simulation "Moore" "src/vending_machine_moore.v" "tb/tb_vending_machine_moore.v" "build/moore_sim"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All simulations completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "VCD waveform files generated:"
echo "  - build/tb_vending_machine_mealy.vcd"
echo "  - build/tb_vending_machine_moore.vcd"
echo ""
echo "To view waveforms, use:"
echo "  gtkwave build/tb_vending_machine_mealy.vcd"
echo "  gtkwave build/tb_vending_machine_moore.vcd"
echo ""
