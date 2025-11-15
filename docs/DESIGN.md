# Vending Machine Controller - Design Documentation

## Table of Contents
1. [Overview](#overview)
2. [Specification](#specification)
3. [State Machine Design](#state-machine-design)
4. [Implementation Details](#implementation-details)
5. [Verification Strategy](#verification-strategy)

## Overview

The Vending Machine Controller is a digital system that manages coin inputs, tracks the total amount collected, dispenses items when sufficient payment is received, and returns appropriate change. This document details both Moore and Mealy FSM implementations.

### System Requirements

**Functional Requirements:**
- Accept coins of denominations: 1₹, 2₹, and 5₹
- Item price: 7₹
- Dispense item when payment ≥ 7₹
- Return change for overpayment (max 3₹)
- Support transaction reset

**Non-Functional Requirements:**
- Synchronous operation with clock
- Asynchronous reset capability
- Maximum total tracked: 10₹
- Single-cycle coin input processing

## Specification

### Interface Definition

```verilog
module vending_machine_X (
    input  wire       clk,      // System clock
    input  wire       reset,    // Active high reset
    input  wire [2:0] coin,     // Coin input encoding
    output reg        dispense, // Item dispense signal
    output reg  [2:0] change,   // Change amount
    output reg  [3:0] total     // Total collected
);
```

### Coin Encoding

| Binary Value | Denomination | Description |
|--------------|--------------|-------------|
| `3'b000`     | 0₹           | No coin inserted |
| `3'b001`     | 1₹           | One rupee coin |
| `3'b010`     | 2₹           | Two rupee coin |
| `3'b101`     | 5₹           | Five rupee coin |
| Other values | Invalid      | Treated as no coin |

### Change Calculation

| Total Payment | Change Returned |
|---------------|-----------------|
| 7₹            | 0₹              |
| 8₹            | 1₹              |
| 9₹            | 2₹              |
| 10₹           | 3₹              |
| >10₹          | 3₹ (capped)     |

## State Machine Design

### Moore FSM States

Moore FSM has 11 states representing different amounts collected:

| State | Value | Description |
|-------|-------|-------------|
| IDLE  | 0     | Initial state, no money collected |
| S1    | 1     | 1₹ collected |
| S2    | 2     | 2₹ collected |
| S3    | 3     | 3₹ collected |
| S4    | 4     | 4₹ collected |
| S5    | 5     | 5₹ collected |
| S6    | 6     | 6₹ collected |
| S7    | 7     | 7₹ collected - Dispense with 0₹ change |
| S8    | 8     | 8₹ collected - Dispense with 1₹ change |
| S9    | 9     | 9₹ collected - Dispense with 2₹ change |
| S10   | 10    | 10₹ collected - Dispense with 3₹ change |

**State Diagram (Moore FSM):**
```
         [Reset]
            |
            v
         ┌─────┐
         │IDLE │ (Total=0, Dispense=0)
         └──┬──┘
            │ 1₹/2₹/5₹
            v
      ┌────┴────┐
      │ S1-S6   │ (Accumulating, Dispense=0)
      └────┬────┘
           │ Coin input
           v
      ┌────┴────┐
      │ S7-S10  │ (Dispense=1, Change varies)
      └────┬────┘
           │
           v
         [IDLE]
```

**Output Characteristics (Moore):**
- Outputs depend ONLY on current state
- Dispense signal active in states S7-S10
- Change value determined by state (S7=0, S8=1, S9=2, S10=3)
- One clock cycle delay for output change

### Mealy FSM States

Mealy FSM has 7 states, fewer than Moore due to output dependency on inputs:

| State | Value | Description |
|-------|-------|-------------|
| IDLE  | 0     | Initial state, no money collected |
| S1    | 1     | 1₹ collected |
| S2    | 2     | 2₹ collected |
| S3    | 3     | 3₹ collected |
| S4    | 4     | 4₹ collected |
| S5    | 5     | 5₹ collected |
| S6    | 6     | 6₹ collected |

**State Diagram (Mealy FSM):**
```
         [Reset]
            |
            v
         ┌─────┐
         │IDLE │
         └──┬──┘
            │ Coin input
            v
      ┌────┴────┐
      │ S1-S6   │ (Accumulating)
      └────┬────┘
           │ If (current + coin) ≥ 7₹
           │ → Dispense=1, Calculate change
           │ → Next state = IDLE
           │
           │ Else
           │ → Continue accumulating
           v
```

**Output Characteristics (Mealy):**
- Outputs depend on BOTH current state AND current input
- Dispense signal activated during transition if total ≥ 7₹
- Same-cycle response to inputs
- More complex output logic

### Comparison Table

| Aspect | Moore FSM | Mealy FSM |
|--------|-----------|-----------|
| States | 11 (IDLE, S1-S10) | 7 (IDLE, S1-S6) |
| Output Timing | Next clock edge | Current cycle |
| Output Logic | Simple (state only) | Complex (state + input) |
| Dispense Delay | 1 cycle | 0 cycles (immediate) |
| Hardware | More flip-flops | Less flip-flops |
| Design | Easier to debug | More efficient |

## Implementation Details

### State Transition Logic

Both implementations use a three-always-block architecture:
1. **Sequential Block**: State register update
2. **Combinational Block**: Next state logic
3. **Output Block**: Output generation

**Sequential Block (Common to both):**
```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
```

### Moore FSM - Next State Logic

States S1-S6 compute next state based on current amount + coin value:
- If total < 7₹: Stay in accumulating states
- If total ≥ 7₹: Transition to appropriate dispense state (S7-S10)
- All dispense states (S7-S10) return to IDLE in next cycle

### Moore FSM - Output Logic

```verilog
always @(*) begin
    case (current_state)
        IDLE, S1-S6: begin
            dispense = 0;
            change = 3'b000;
            total = current_state;
        end
        S7:  begin dispense = 1; change = 3'b000; total = 7; end
        S8:  begin dispense = 1; change = 3'b001; total = 8; end
        S9:  begin dispense = 1; change = 3'b010; total = 9; end
        S10: begin dispense = 1; change = 3'b011; total = 10; end
    endcase
end
```

### Mealy FSM - Output Logic

The output logic checks if the current coin input will cause dispensing:

```verilog
always @(*) begin
    if ((current_state + coin) >= 7) begin
        dispense = 1;
        change = (current_state + coin) - 7;
        total = current_state + coin;
    end else begin
        dispense = 0;
        change = 0;
        total = current_state;
    end
end
```

### Critical Design Decisions

1. **Maximum Amount Capping**: Both designs cap total at 10₹ to prevent overflow
2. **Change Limitation**: Maximum change is 3₹ (10₹ - 7₹)
3. **Invalid Coin Handling**: Unrecognized coin values treated as no input
4. **Reset Behavior**: Asynchronous reset immediately returns to IDLE
5. **Coin Persistence**: Each coin input processed for one clock cycle

## Verification Strategy

### Testbench Architecture

Both testbenches follow a structured approach:
1. Clock generation (100MHz, 10ns period)
2. Reset sequence initialization
3. Comprehensive test case execution
4. VCD waveform dumping
5. Automatic verification with $display statements

### Test Coverage

| Test Category | Description | Test Cases |
|---------------|-------------|------------|
| Basic Functionality | Single transaction tests | 5 cases |
| Edge Cases | Reset, invalid input | 2 cases |
| Boundary Testing | Minimum/maximum payments | Included |
| Mixed Scenarios | Various coin combinations | Multiple |

### Test Cases Summary

1. **Exact Payment**: Various combinations summing to 7₹
2. **Overpayment**: Amounts > 7₹ with change verification
3. **Incremental**: Multiple small denomination coins
4. **Reset Testing**: Mid-transaction reset behavior
5. **Idle Testing**: No coin input verification

### Verification Metrics

- **State Coverage**: All states reached and tested
- **Transition Coverage**: All valid state transitions exercised
- **Output Verification**: Dispense and change values validated
- **Timing Verification**: Waveform analysis for timing correctness

### Waveform Analysis

Key signals to observe in GTKWave:
- `clk`: Clock signal
- `reset`: Reset pulse
- `coin[2:0]`: Coin input sequence
- `current_state[3:0]`: State progression
- `total[3:0]`: Running total
- `dispense`: Item dispense activation
- `change[2:0]`: Change return value

## Simulation Results

Expected simulation output includes:
- Clear test case descriptions
- Step-by-step transaction tracking
- Total accumulation logging
- Dispense signal verification
- Change calculation validation

Example output:
```
========================================
Vending Machine Mealy FSM Test
Item Price: 7 Rupees
========================================

Test Case 1: Insert 2₹ + 5₹ (Total = 7₹)
  After 2₹: Total = 2, Dispense = 0, Change = 0
  After 5₹: Total = 7, Dispense = 1, Change = 0
  After transaction: Total = 0
```

## Synthesis Considerations

### Resource Utilization

**Moore FSM:**
- More state bits (4 bits for 11 states)
- Simpler combinational logic
- Predictable timing

**Mealy FSM:**
- Fewer state bits (3 bits for 7 states)
- More complex combinational logic
- Faster response time

### Timing Analysis

- **Setup Time**: Ensure coin inputs stable before clock edge
- **Clock-to-Q**: Moore has additional output delay
- **Combinational Delay**: Mealy has longer combinational paths

### Design Trade-offs

| Consideration | Moore Advantage | Mealy Advantage |
|---------------|-----------------|-----------------|
| Response Time | - | ✓ Faster |
| State Count | - | ✓ Fewer states |
| Output Glitches | ✓ Less prone | - |
| Design Simplicity | ✓ Simpler outputs | - |
| Hardware Cost | - | ✓ Less flip-flops |
| Debugging | ✓ Easier | - |

## Future Enhancements

Possible improvements:
1. Add multi-item selection support
2. Implement coin return mechanism
3. Add LCD display interface
4. Support for more coin denominations
5. Transaction history logging
6. Low power mode implementation
7. Error detection and recovery

## References

1. Digital Design and Computer Architecture - Harris & Harris
2. Verilog HDL: A Guide to Digital Design and Synthesis - Samir Palnitkar
3. FSM-based Design - Best Practices and Guidelines
4. IEEE Standard Verilog Language Reference Manual

---

**Document Version**: 1.0  
**Last Updated**: November 2025  
**Author**: kunal885911
