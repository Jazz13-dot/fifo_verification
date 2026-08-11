# 8-bit Synchronous FIFO using Verilog

![Language](https://img.shields.io/badge/Language-Verilog%20HDL-blue)
![Tool](https://img.shields.io/badge/Tool-Vivado%202025.2-orange)
![Simulation](https://img.shields.io/badge/Simulation-Xilinx%20XSIM-green)
![Status](https://img.shields.io/badge/Status-Simulation%20Verified-brightgreen)

---

## Overview

This project implements an **8-bit wide, 8-depth synchronous FIFO** (First-In First-Out) buffer in Verilog HDL. A FIFO is a fundamental digital design block used for buffering data between two modules operating at the same or different rates. In this synchronous design, both read and write operations share a **single clock**, making it straightforward to integrate into a single clock-domain system.

The design provides **full** and **empty** status flags, a registered data output, and an occupancy counter to track the number of valid entries. Functional correctness was verified using Xilinx XSIM behavioral simulation in Vivado 2025.2.

---

## Features

- ✅ 8-bit data width
- ✅ 8-entry FIFO depth (64 bits total storage)
- ✅ Single-clock synchronous operation
- ✅ Active-high synchronous reset
- ✅ Write enable and Read enable control signals
- ✅ `full` and `empty` status flags
- ✅ Occupancy counter for tracking stored entries
- ✅ Registered (sequential) data output
- ✅ Behavioral simulation verified with XSIM

---

## Architecture / Working Principle

### Internal Block Description

| Block | Description |
|---|---|
| **Memory Array** | A 2D register array `mem[7:0]` with 8 locations, each 8 bits wide, used to store the FIFO data entries. |
| **Write Pointer** | A 3-bit pointer (`wr_ptr`) that tracks the location where the next write will occur. It advances by 1 after every valid write operation. |
| **Read Pointer** | A 3-bit pointer (`rd_ptr`) that tracks the location of the next data to be read. It advances by 1 after every valid read operation. |
| **Occupancy Counter** | A 4-bit counter (`count`) that holds the current number of valid entries stored in the FIFO. It increments on a write, decrements on a read, and does both simultaneously on a concurrent read/write. |
| **Full Flag** | Asserted (`full = 1`) when the occupancy counter reaches 8, indicating that all FIFO locations are occupied and no more writes should be performed. |
| **Empty Flag** | Asserted (`empty = 1`) when the occupancy counter is 0, indicating there is no data available for reading. |
| **Registered Data Output** | The `dout` signal is updated on the rising edge of `clk` during a valid read, ensuring a clean, synchronous output. |

### FIFO Operation

All operations are synchronized to the **rising edge of `clk`**.

1. **Reset** — When `rst` is asserted (high), the write pointer, read pointer, occupancy counter, and data output are all cleared. The FIFO enters an empty state.
2. **Write** — When `wr_en` is high and the FIFO is **not full**, the value on `din` is written into `mem[wr_ptr]`. The write pointer then advances to the next location.
3. **Read** — When `rd_en` is high and the FIFO is **not empty**, the value at `mem[rd_ptr]` is driven onto `dout`. The read pointer then advances to the next location.
4. **Write Pointer Advance** — `wr_ptr` is incremented after every successful write.
5. **Read Pointer Advance** — `rd_ptr` is incremented after every successful read.
6. **Occupancy Tracking** — `count` increments on write-only, decrements on read-only, and remains unchanged during a simultaneous read and write (since one entry enters and one exits).
7. **Empty Condition** — `empty = 1` when `count == 0`. Reads are blocked while the FIFO is empty.
8. **Full Condition** — `full = 1` when `count == 8`. Writes are blocked while the FIFO is full.
9. **Clock Synchronization** — Every state transition (pointer updates, memory writes, output register updates) occurs on the **rising edge of `clk`**, making this a purely synchronous design.

---

## Signal Description

| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| `clk` | Input | 1 bit | FIFO clock — all operations are synchronous to the rising edge |
| `rst` | Input | 1 bit | Active-high synchronous reset — clears pointers, counter, and output |
| `wr_en` | Input | 1 bit | Write enable — when high, allows data to be written into the FIFO |
| `rd_en` | Input | 1 bit | Read enable — when high, allows data to be read from the FIFO |
| `din` | Input | 8 bits | Data input — the 8-bit value to be written into the FIFO |
| `dout` | Output | 8 bits | Data output — the 8-bit value read from the FIFO |
| `full` | Output | 1 bit | Full flag — asserted when all 8 FIFO entries are occupied |
| `empty` | Output | 1 bit | Empty flag — asserted when the FIFO contains no valid data |

---

## File Structure

```
8bit-sync-fifo/
│
├── fifo.v          # RTL design — synchronous FIFO implementation
├── fifo_tb.v       # Verilog testbench — functional verification
└── README.md       # Project documentation
```

- **`fifo.v`** — Contains the synthesizable RTL design of the synchronous FIFO, including the memory array, read/write pointers, occupancy counter, and status flags.
- **`fifo_tb.v`** — Contains the self-contained testbench that applies stimulus to the FIFO and exercises various read, write, and edge-case scenarios.

---

## Simulation / Verification

### Testbench Overview

The testbench (`fifo_tb.v`) is written in Verilog and exercises the FIFO through the following test scenarios:

| Test Scenario | Description |
|---|---|
| **Clock Generation** | A periodic clock with a 10 ns period (100 MHz) is generated using an `always` block. |
| **Reset Application** | `rst` is asserted for a few clock cycles at the start to initialize the FIFO to a known empty state. |
| **Write Operations** | Multiple sequential write transactions are performed to push data into the FIFO. |
| **Read Operations** | Multiple sequential read transactions are performed to pop data from the FIFO. |
| **Simultaneous Read/Write** | `wr_en` and `rd_en` are asserted together to verify that the FIFO correctly handles concurrent read and write in the same clock cycle. |
| **FIFO Ordering** | The order of data read back from the FIFO is observed to confirm first-in, first-out behavior. |
| **Flag Observation** | The `full` and `empty` flags are observed at appropriate points to confirm they assert and deassert correctly. |

### Simulation Steps

1. Open the project in **Vivado 2025.2**.
2. Add `fifo.v` to **Design Sources**.
3. Add `fifo_tb.v` to **Simulation Sources**.
4. Click **Run Behavioral Simulation** (or use `launch_simulation` in the Tcl console).
5. In the waveform window, add the following signals: `clk`, `rst`, `wr_en`, `rd_en`, `din`, `dout`, `full`, `empty`.
6. Run the simulation for a sufficient number of cycles and inspect the FIFO behavior on the waveform.

> **Note:** The simulation was run using Xilinx XSIM. No hardware implementation or synthesis was performed as part of this project.

---

## Expected Behavior

| Condition | Expected Output |
|---|---|
| After reset | `empty = 1`, `full = 0`, `dout = 0` |
| After 8 consecutive writes | `full = 1`, `empty = 0` |
| After 8 consecutive reads (following full) | `empty = 1`, `full = 0` |
| During valid writes | Data enters the FIFO in the order it was presented on `din` |
| During valid reads | Data exits the FIFO in the same order it was written (FIFO ordering preserved) |
| Write when `full = 1` | Write is ignored; FIFO contents remain unchanged |
| Read when `empty = 1` | Read is ignored; `dout` retains its last value |
| Simultaneous read and write | One entry exits and one entry enters; occupancy count remains the same |

---

## Learning Outcomes

This project covers the following digital design concepts:

- **RTL Design** — Describing hardware behavior using synthesizable Verilog constructs
- **Sequential Logic** — Designing state-holding elements clocked by a single system clock
- **Memory Arrays** — Implementing storage using 2D register arrays in Verilog
- **Read/Write Pointers** — Managing circular buffer addressing with separate read and write pointers
- **FIFO Status Flags** — Deriving `full` and `empty` conditions from an occupancy counter
- **Synchronous Design** — Ensuring all state transitions occur on a single clock edge for predictable timing
- **Verilog HDL** — Practising industry-standard hardware description language syntax and style
- **Functional Simulation and Waveform Analysis** — Verifying RTL designs using testbenches and interpreting signal waveforms in Vivado XSIM

---

## Future Improvements

The following enhancements could be explored as extensions of this project:

- **Parameterized FIFO** — Use Verilog `parameter` statements to make the data width and FIFO depth configurable at instantiation time.
- **Almost-Full / Almost-Empty Flags** — Add threshold-based flags to give early warning before the FIFO reaches its limits, useful in flow-control applications.
- **Overflow / Underflow Detection** — Add logic to detect and flag attempted writes to a full FIFO or reads from an empty FIFO.
- **Assertion-Based Verification** — Incorporate SystemVerilog assertions (SVA) to formally state design intent and catch protocol violations during simulation.
- **BRAM Inference** — Replace the register-based memory array with a block RAM (BRAM) inference style for larger FIFO depths, improving resource utilization on Xilinx FPGAs.
- **Asynchronous FIFO** — Extend the design to support independent read and write clock domains using Gray-code pointers, for use in clock domain crossing (CDC) scenarios.

---

## Author

**Diwakar**
B.Tech — Electronics and Communication Engineering

> *This project was developed for learning and academic purposes using Vivado 2025.2 and Xilinx XSIM behavioral simulation.*
