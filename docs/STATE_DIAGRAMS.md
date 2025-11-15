# State Diagrams

## Vending Machine Controller State Diagrams

This document contains ASCII-art state diagrams for both Moore and Mealy FSM implementations.

---

## Moore FSM State Diagram

```
Item Price: 7₹  |  Coins: 1₹, 2₹, 5₹  |  Change: 0-3₹

                              ┌──────────┐
                              │  RESET   │
                              └────┬─────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │     IDLE     │
                            │   Total: 0   │
                            │  Dispense: 0 │
                            │   Change: 0  │
                            └──────┬───────┘
                ┌──────────────────┼──────────────────┐
                │ 1₹               │ 2₹               │ 5₹
                ▼                  ▼                  ▼
         ┌──────────┐       ┌──────────┐      ┌──────────┐
         │    S1    │       │    S2    │      │    S5    │
         │ Total: 1 │       │ Total: 2 │      │ Total: 5 │
         │Dispense:0│       │Dispense:0│      │Dispense:0│
         │ Change:0 │       │ Change:0 │      │ Change:0 │
         └────┬─────┘       └────┬─────┘      └────┬─────┘
              │                  │                   │
    ┌─────────┼──────────────────┼───────────────────┤
    │ 1₹      │ 2₹           1₹  │ 5₹            1₹  │ 2₹
    │         ▼                  ▼                   ▼
    │   ┌──────────┐       ┌──────────┐      ┌──────────┐
    │   │    S2    │       │    S3    │      │    S6    │
    │   │ Total: 2 │       │ Total: 3 │      │ Total: 6 │
    │   │Dispense:0│       │Dispense:0│      │Dispense:0│
    │   │ Change:0 │       │ Change:0 │      │ Change:0 │
    │   └────┬─────┘       └────┬─────┘      └────┬─────┘
    │        │                   │                  │
    │        │ 1₹/2₹/5₹          │ 1₹/2₹/5₹        │ 1₹
    │        ▼                   ▼                  ▼
    │   ┌──────────┐       ┌──────────┐      ┌──────────┐
    └──▶│    S3    │       │    S4    │      │    S7    │◀─┐
        │ Total: 3 │       │ Total: 4 │      │ Total: 7 │  │
        │Dispense:0│       │Dispense:0│      │Dispense:1│  │
        │ Change:0 │       │ Change:0 │      │ Change:0 │  │
        └────┬─────┘       └────┬─────┘      └────┬─────┘  │
             │                   │                  │        │
             │ 1₹/2₹/5₹          │ 1₹/2₹/5₹        │        │
             ▼                   ▼                  │        │
        ┌──────────┐       ┌──────────┐            │        │
        │    S4    │       │    S5    │            │        │
        │ Total: 4 │       │ Total: 5 │            │        │
        │Dispense:0│       │Dispense:0│            │        │
        │ Change:0 │       │ Change:0 │            │        │
        └────┬─────┘       └────┬─────┘            │        │
             │                   │                  │        │
             │ 1₹/2₹/5₹          │ 2₹               │        │
             ▼                   └──────────────────┘        │
        ┌──────────┐                                         │
        │    S5    │             ┌──────────┐                │
        │ Total: 5 │     ┌──────▶│    S8    │                │
        │Dispense:0│     │ 2₹    │ Total: 8 │                │
        │ Change:0 │     │       │Dispense:1│                │
        └────┬─────┘     │       │ Change:1 │                │
             │           │       └────┬─────┘                │
             │ 1₹        │            │                      │
             ▼           │            └──────────────────────┤
        ┌──────────┐     │                                   │
        │    S6    │─────┘       ┌──────────┐                │
        │ Total: 6 │─────────────▶    S9    │                │
        │Dispense:0│     5₹      │ Total: 9 │                │
        │ Change:0 │             │Dispense:1│                │
        └────┬─────┘             │ Change:2 │                │
             │                   └────┬─────┘                │
             │ 5₹                     │                      │
             ▼                        └──────────────────────┤
        ┌──────────┐                                         │
        │   S10    │                                         │
        │ Total:10 │─────────────────────────────────────────┘
        │Dispense:1│           All S7-S10 return to IDLE
        │ Change:3 │           on next clock cycle
        └──────────┘

Legend:
  ─▶  State Transition
  │   Vertical flow
  ┌─┐ State box
```

---

## Mealy FSM State Diagram

```
Item Price: 7₹  |  Coins: 1₹, 2₹, 5₹  |  Change: 0-3₹

                              ┌──────────┐
                              │  RESET   │
                              └────┬─────┘
                                   │
                                   ▼
                            ┌──────────────┐
                            │     IDLE     │
                            │   Total: 0   │
                            └──────┬───────┘
                ┌──────────────────┼──────────────────┐
                │ 1₹               │ 2₹               │ 5₹
                ▼                  ▼                  ▼
         ┌──────────┐       ┌──────────┐      ┌──────────┐
         │    S1    │       │    S2    │      │    S5    │
         │ Total: 1 │       │ Total: 2 │      │ Total: 5 │
         └────┬─────┘       └────┬─────┘      └────┬─────┘
              │                  │                   │
    ┌─────────┼──────────────────┼───────────────────┤
    │ 1₹      │ 2₹           1₹  │                1₹ │ 2₹
    │         │              │   │ 5₹/Disp+0        │ │
    │         ▼              ▼   └──────┐           ▼ │
    │   ┌──────────┐  ┌──────────┐     │     ┌──────────┐
    │   │    S2    │  │    S3    │     │     │    S6    │
    │   │ Total: 2 │  │ Total: 3 │     │     │ Total: 6 │
    │   └────┬─────┘  └────┬─────┘     │     └────┬─────┘
    │        │             │            │          │
    │        │ 1₹          │ 1₹         │          │ 1₹/Disp+0
    │        │             │            │          ├────────┐
    │        ▼             ▼            │          │        │
    │   ┌──────────┐  ┌──────────┐     │  5₹/     │  2₹/   │
    └──▶│    S3    │  │    S4    │     │  Disp+3  │  Disp+1│
        │ Total: 3 │  │ Total: 4 │     │          │        │
        └────┬─────┘  └────┬─────┘     │          │        │
             │             │            │          │        │
             │ 1₹          │ 1₹         │          ▼        ▼
             │             │            │       ┌──────────────┐
             ▼             ▼            └──────▶│     IDLE     │
        ┌──────────┐  ┌──────────┐             │   Total: 0   │
        │    S4    │  │    S5    │◀──┐         └──────────────┘
        │ Total: 4 │  │ Total: 5 │   │
        └────┬─────┘  └────┬─────┘   │
             │             │          │
             │ 2₹          │ 1₹       │ 2₹/Disp+0
             │             │          │
             ▼             ▼          │
        ┌──────────┐  ┌──────────┐   │
        │    S5    │  │    S6    │───┘
        │ Total: 5 │  │ Total: 6 │
        └────┬─────┘  └──────────┘
             │
             │ 5₹/Disp+3
             │
             ▼
        ┌──────────────┐
        │     IDLE     │
        │   Total: 0   │
        └──────────────┘

Output Behavior (Mealy):
─────────────────────────────────────────────────────────────
│ State │  Coin  │ Next State │ Dispense │ Change │ Total │
├───────┼────────┼────────────┼──────────┼────────┼───────┤
│  S2   │  5₹    │    IDLE    │    1     │   0    │   7   │
│  S3   │  5₹    │    IDLE    │    1     │   1    │   8   │
│  S4   │  5₹    │    IDLE    │    1     │   2    │   9   │
│  S5   │  2₹    │    IDLE    │    1     │   0    │   7   │
│  S5   │  5₹    │    IDLE    │    1     │   3    │  10   │
│  S6   │  1₹    │    IDLE    │    1     │   0    │   7   │
│  S6   │  2₹    │    IDLE    │    1     │   1    │   8   │
│  S6   │  5₹    │    IDLE    │    1     │   3    │  10   │
─────────────────────────────────────────────────────────────

Key Differences from Moore:
  • Outputs change IMMEDIATELY when input changes (same cycle)
  • No separate "dispense" states needed
  • Fewer total states (7 vs 11)
  • Dispense decision made during transition
  • More complex output logic

Legend:
  ─▶  State Transition
  │   Vertical flow
  Disp Dispense signal active
  +N   Change amount
```

---

## Timing Diagrams

### Moore FSM Timing

```
Clock    ┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
         └───┘   └───┘   └───┘   └───┘   └───┘   └───

Coin     ──────< 2₹ >───────────< 5₹ >───────────────
                   
State    ──[IDLE]──[S2]───[S2]───[S7]───[S7]──[IDLE]

Total    ───< 0 >──< 2 >──< 2 >──< 7 >──< 7 >──< 0 >

Dispense ───────────────────────────────┌─────────────
                                        └─────────────

Change   ───< 0 >──< 0 >──< 0 >──< 0 >──< 0 >──< 0 >

Note: Output changes occur one clock cycle after state change
```

### Mealy FSM Timing

```
Clock    ┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐
         └───┘   └───┘   └───┘   └───┘   └───┘   └───

Coin     ──────< 2₹ >───────────< 5₹ >───────────────
                   
State    ──[IDLE]──[S2]───[S2]──[IDLE]─[IDLE]─[IDLE]

Total    ───< 0 >──< 2 >──< 2 >──< 7 >──< 0 >──< 0 >

Dispense ────────────────────────┌─────────────────────
                                 └─────────────────────

Change   ───< 0 >──< 0 >──< 0 >──< 0 >──< 0 >──< 0 >

Note: Output changes occur SAME CYCLE as input change
      No separate dispense state needed
```

---

## State Transition Table - Moore FSM

```
┌─────────────┬──────────┬──────────┬──────────┬──────────┐
│ Current     │ Coin=1₹  │ Coin=2₹  │ Coin=5₹  │ No Coin  │
│ State       │          │          │          │          │
├─────────────┼──────────┼──────────┼──────────┼──────────┤
│ IDLE (0)    │   S1     │   S2     │   S5     │  IDLE    │
│ S1   (1)    │   S2     │   S3     │   S6     │   S1     │
│ S2   (2)    │   S3     │   S4     │   S7     │   S2     │
│ S3   (3)    │   S4     │   S5     │   S8     │   S3     │
│ S4   (4)    │   S5     │   S6     │   S9     │   S4     │
│ S5   (5)    │   S6     │   S7     │   S10    │   S5     │
│ S6   (6)    │   S7     │   S8     │   S10    │   S6     │
│ S7   (7)    │  IDLE    │  IDLE    │  IDLE    │  IDLE    │
│ S8   (8)    │  IDLE    │  IDLE    │  IDLE    │  IDLE    │
│ S9   (9)    │  IDLE    │  IDLE    │  IDLE    │  IDLE    │
│ S10  (10)   │  IDLE    │  IDLE    │  IDLE    │  IDLE    │
└─────────────┴──────────┴──────────┴──────────┴──────────┘
```

## State Transition Table - Mealy FSM

```
┌─────────────┬──────────┬──────────┬──────────┬──────────┐
│ Current     │ Coin=1₹  │ Coin=2₹  │ Coin=5₹  │ No Coin  │
│ State       │          │          │          │          │
├─────────────┼──────────┼──────────┼──────────┼──────────┤
│ IDLE (0)    │   S1     │   S2     │   S5     │  IDLE    │
│ S1   (1)    │   S2     │   S3     │   S6     │   S1     │
│ S2   (2)    │   S3     │   S4     │  IDLE*   │   S2     │
│ S3   (3)    │   S4     │   S5     │  IDLE*   │   S3     │
│ S4   (4)    │   S5     │   S6     │  IDLE*   │   S4     │
│ S5   (5)    │   S6     │  IDLE*   │  IDLE*   │   S5     │
│ S6   (6)    │  IDLE*   │  IDLE*   │  IDLE*   │   S6     │
└─────────────┴──────────┴──────────┴──────────┴──────────┘

* Transitions marked with * trigger dispense signal
  Change is calculated as: (CurrentState + Coin) - 7
```

---

## Visual Comparison

### State Count
```
Moore FSM:  ●●●●●●●●●●●  (11 states)
Mealy FSM:  ●●●●●●●     (7 states)
```

### Response Time
```
Moore FSM:  Input ──▶ [1 CLK] ──▶ Output
Mealy FSM:  Input ──▶ [0 CLK] ──▶ Output
```

### Hardware Complexity
```
Moore FSM:  
  State Bits:  ████ (4 bits for 11 states)
  Output Logic: ▓▓ (Simple)

Mealy FSM:  
  State Bits:  ███ (3 bits for 7 states)
  Output Logic: ▓▓▓▓ (Complex)
```

---

**Document Version**: 1.0  
**Last Updated**: November 2025
