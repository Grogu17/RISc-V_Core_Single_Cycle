# RISc-V_Core_Single_Cycle
A 32-bit (RV32I) RISC V Single Cycle Processor core implemented in Verilog. Features a validated 32-bit ALU; currently developing the instruction decoder and register file for base integer instructions.

# 32-bit RISC-V (RV32I) Single-Cycle Processor 

### Project Status: Active Development / RTL Design Phase
This repository contains a 32-bit RISC-V processor core implemented in Verilog. I am currently transitioning from building independent modules to integrating the full single-cycle datapath.

### Technical Specifications
* Architecture: RISC-V (RV32I Base Integer Instruction Set)
* Data Width: 32-bit
* Design Methodology: Modular RTL using two-level decoding (Main + ALU Decoder)

### Current Progress (Implemented Modules)
* 32-bit ALU: Supports ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, and SLTU.
* Control Unit: Includes a "Main Decoder" for opcode mapping and an "ALU Decoder" for functional switching.
* Memory Units: Implementation of a 1024-deep "Instruction Memory" and "Data Memory".
* Register File: 32x32-bit dual-read/single-write register bank with x0 hardwired to zero.
* Program Counter (PC): Synchronous reset logic for instruction sequencing.

### In-Progress / Next Steps
* Datapath Integration: Finalizing the `PC_Next` logic and wiring the multiplexers in the `single_cycle_top` module.
* Verification: Developing comprehensive testbenches for individual modules and full-system simulation in Xilinx Vivado.

### Development Stack
* HDL: Verilog
* Editor: VS Code
* Synthesis/Simulation: Xilinx Vivado
