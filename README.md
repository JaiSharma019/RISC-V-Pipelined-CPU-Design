# Custom RV32I 5-Stage Pipelined Processor

A 32-bit RISC-V (RV32I) processor designed from scratch in Verilog. The core implements a 5 stage pipeline Fetch, Decode, Execute, Memory and Write Back stages, and is fully verified using compiled C programs.

## Key Features

* **Full Data-Hazard Bypassing**: Custom forwarding_unit file resolves Read after write (RAW) hazards dynamically, achieving zero stall execution for ALU dependent instruction sequences.

* **Load-Use Interlock**: Centralized hazard detection dynamically freezes the pipeline to resolve memory latency stalls.

* **Early Branch Resolution**: Comparators and target address adders are instantiated in the Decode (ID) stage, minimizing static "Predict Not Taken" misprediction penalties to a single cycle.

* **Byte-Addressable Memory**: Fully compliant SRAM interface handling LB, LH, LW, SB, SH and SW with proper sign extension and masking.

## Verification Strategy

The processor's correctness was verified by cross compiling standard C algorithms (like Linked-List Traversal, Quicksort, Bellman-Ford and Matrix Multiplication) into RISC-V machine code using the riscv-none-elf-gcc toolchain.

The testbench (core_tb.v) executes the machine code, tracks hardware performance counters (cycles, stalls, flushes), and dumps the final state of the SRAM into a final_memory_dump.hex file. The output inside the .signature memory region is then validated against expected algorithmic results.

## Performance Metrics

Calculated the performance using testbench simulation using Icarus Verilog for various algorithms.
Below are the results for Lineked List Traversal algorithm, testing the load use dependencies and control flow branches.

| Metric | Value |
| ----- | ----- |
| **Total Clock Cycles** | 210 | 
| **Instructions Retired** | 154 | 
| **Data Hazard Stalls** | 44 | 
| **Branch Penalties** | 8 | 
| **CPI (Cycles Per Instruction)** | **1.338** | 
| **IPC (Instructions Per Cycle)** | **0.748** |

*(Note: Ideal CPI for a scalar pipeline is 1.0. The difference arises due to memory latency constraints)*

## Repository Structure

* `/src` - Contains all Verilog RTL modules (core.v, fetch.v, forwarding_unit.v, alu.v, etc.)

* `/tb` - Contains the primary testbench (core_tb.v) and hardware performance counters.

* `/software` - Contains C program (main.c), linker files for verification, with the compiled program.hex file.

## Running the Simulation

This project uses Icarus Verilog for simulation.

Clone the repository:
```bash
git clone https://github.com/JaiSharma019/RISC-V-Pipelined-CPU-Design.git
cd RISC-V-Pipelined-CPU-Design
```

To compile the Verilog files:

```bash
iverilog -o sim.vvp src/*.v tb/core_tb.v
```

Execute the simulation:

```bash
vvp sim.vvp
```
