# Quick Start Guide

This guide will help you get started with the Vending Machine Controller project.

## Installation

### Step 1: Install Prerequisites

**For Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

**For macOS:**
```bash
brew install icarus-verilog gtkwave
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/kunal885911/vending-machine-verilog.git
cd vending-machine-verilog
```

## Running Simulations

### Method 1: Using Make (Recommended)

```bash
# Run Mealy FSM simulation
make mealy

# Run Moore FSM simulation
make moore

# Run both simulations
make test

# Clean build artifacts
make clean
```

### Method 2: Using Shell Scripts

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Run all simulations
./scripts/run_simulation.sh
```

### Method 3: Manual Execution

```bash
# Create build directory
mkdir -p build

# Compile Mealy FSM
iverilog -g2012 -Wall -o build/mealy_sim \
    src/vending_machine_mealy.v \
    tb/tb_vending_machine_mealy.v

# Run Mealy simulation
vvp build/mealy_sim

# Compile Moore FSM
iverilog -g2012 -Wall -o build/moore_sim \
    src/vending_machine_moore.v \
    tb/tb_vending_machine_moore.v

# Run Moore simulation
vvp build/moore_sim
```

## Viewing Waveforms

After running simulations, VCD (Value Change Dump) files are generated in the `build/` directory.

### Using GTKWave

```bash
# View Mealy FSM waveforms
make wave-mealy
# OR
gtkwave build/tb_vending_machine_mealy.vcd

# View Moore FSM waveforms
make wave-moore
# OR
gtkwave build/tb_vending_machine_moore.vcd
```

### Using Pre-configured GTKWave Views

```bash
# With custom signal configuration
gtkwave build/tb_vending_machine_mealy.vcd scripts/mealy_wave.gtkw
gtkwave build/tb_vending_machine_moore.vcd scripts/moore_wave.gtkw
```

## Understanding the Output

### Simulation Console Output

```
========================================
Vending Machine Mealy FSM Test
Item Price: 7 Rupees
========================================

Test Case 1: Insert 2₹ + 5₹ (Total = 7₹)
  After 2₹: Total =  2, Dispense = 0, Change = 0
  After 5₹: Total =  7, Dispense = 1, Change = 0
  After transaction: Total =  0
```

**Understanding the output:**
- `Total`: Current amount collected
- `Dispense`: 1 when item is dispensed, 0 otherwise
- `Change`: Amount of change returned (0-3₹)

### Common Test Scenarios

| Test Case | Input Sequence | Expected Output |
|-----------|----------------|-----------------|
| Exact Payment | 2₹ + 5₹ | Total=7, Dispense=1, Change=0 |
| Overpayment | 5₹ + 5₹ | Total=10, Dispense=1, Change=3 |
| Small Coins | 1₹ × 7 | Total=7, Dispense=1, Change=0 |
| Mixed Coins | 1₹+1₹+2₹+2₹+1₹ | Total=7, Dispense=1, Change=0 |

## Modifying the Design

### Changing the Item Price

Edit the state machine logic in `src/vending_machine_mealy.v` or `src/vending_machine_moore.v`:

```verilog
// Change the price threshold from 7 to desired value
// Update state transition conditions accordingly
```

### Adding New Test Cases

Edit the testbench files `tb/tb_vending_machine_mealy.v` or `tb/tb_vending_machine_moore.v`:

```verilog
// Add after existing test cases
$display("Custom Test: My test scenario");
coin = 3'b001; #10;  // Insert 1₹
coin = 3'b010; #10;  // Insert 2₹
// ... more test logic
```

### Adding New Coin Denominations

1. Update the coin encoding in the module
2. Modify state transition logic
3. Update testbenches
4. Update documentation

## Troubleshooting

### Error: "iverilog: command not found"

**Solution:** Install Icarus Verilog:
```bash
# Ubuntu/Debian
sudo apt-get install iverilog

# macOS
brew install icarus-verilog
```

### Error: "make: command not found"

**Solution:** Install make:
```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# macOS
xcode-select --install
```

### No waveform file generated

**Issue:** VCD file not created after simulation

**Solution:** 
- Ensure simulation completes without errors
- Check that `$dumpfile()` and `$dumpvars()` are in testbench
- Verify write permissions in `build/` directory

### GTKWave shows empty signals

**Issue:** Signals not visible in waveform viewer

**Solution:**
- Click on the module name in the SST (Signal Source Tree)
- Select signals from the bottom-left panel
- Drag them to the Signals panel

## Performance Tips

### Faster Compilation

For large projects, compile only changed modules:
```bash
make compile-mealy  # Only compile, don't run
```

### Parallel Simulation

Run both simulations in parallel:
```bash
make sim-mealy & make sim-moore & wait
```

### Reducing Simulation Time

Edit testbenches to reduce clock cycles or test cases:
```verilog
// Reduce the number of test iterations
repeat(3) begin  // Instead of repeat(10)
    // test logic
end
```

## Advanced Usage

### Custom Makefile Targets

Add custom targets to `Makefile`:
```makefile
.PHONY: quick-test
quick-test:
	@echo "Running quick test..."
	make compile-mealy
	cd build && vvp mealy_sim | grep "Test Case"
```

### Automated Testing

Create a test script:
```bash
#!/bin/bash
make clean
make test > test_results.log 2>&1
if grep -q "All tests completed" test_results.log; then
    echo "✓ All tests passed"
else
    echo "✗ Tests failed"
    exit 1
fi
```

### Continuous Integration

Example GitHub Actions workflow:
```yaml
name: Verilog Simulation
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Icarus Verilog
        run: sudo apt-get install -y iverilog
      - name: Run Tests
        run: make test
```

## Learning Resources

### Understanding State Machines
- `docs/DESIGN.md` - Detailed design documentation
- `docs/STATE_DIAGRAMS.md` - Visual state diagrams

### Verilog Syntax
- Icarus Verilog Documentation: http://iverilog.icarus.com/
- IEEE Verilog Standard: IEEE 1364-2005

### GTKWave Tutorial
1. Open VCD file
2. Select module in SST (left panel)
3. Drag signals to waveform viewer
4. Use Zoom options to adjust time scale
5. Add markers for important events

## Next Steps

1. **Explore the Code**: Read through source files in `src/`
2. **Run Simulations**: Try `make test` to see both FSMs in action
3. **View Waveforms**: Use GTKWave to visualize state transitions
4. **Modify & Experiment**: Change parameters and observe behavior
5. **Read Documentation**: Study `docs/DESIGN.md` for detailed explanations

## Getting Help

- Check documentation in `docs/` directory
- Review README.md for project overview
- Examine test cases in `tb/` directory
- Open issues on GitHub for bugs or questions

## Example Session

```bash
# Complete workflow example
cd vending-machine-verilog

# Run Mealy FSM simulation
make mealy

# Output shows test results
# VCD file created in build/

# View waveforms
make wave-mealy

# GTKWave opens with signals
# Observe state transitions, coin inputs, dispense signals

# Clean up
make clean
```

---

**Happy Simulating! 🚀**

For more information, see the main [README.md](../README.md) or detailed [DESIGN.md](DESIGN.md).
