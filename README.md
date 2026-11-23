# RISc-V_Core_Single_Cycle
A 32-bit (RV32I) RISC V Single Cycle Processor core implemented in Verilog. Features a validated 32-bit ALU; currently developing the instruction decoder and register file for base integer instructions.

# 32-bit RISC-V (RV32I) Single-Cycle Processor

A modular Verilog implementation of a 32-bit single-cycle RV32I processor core.

## Supported Instructions

- **R-type:** `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`
- **I-type:** `ADDI`, `ANDI`, `ORI`, `XORI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU`
- **Loads:** `LB`, `LH`, `LW`, `LBU`, `LHU`
- **Stores:** `SB`, `SH`, `SW`
- **Branches:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **Control flow:** `JAL`, `JALR`
- **Upper immediates:** `LUI`, `AUIPC`

## Architecture

The datapath uses a synchronous PC, 32x32 register file, shared ALU, sign/zero extension unit, byte-capable data memory, instruction memory, and two-level control decoding.

- Register `x0` is hardwired to zero.
- The instruction memory loads machine words from `program.hex`.
- Data memory supports byte, halfword, and word stores and sign/zero-extended loads.
- JALR target addresses are aligned to a 32-bit boundary.
- Illegal opcodes default to safe NOP-like control values.

## Verification

A smoke-test testbench is provided in `tb_single_cycle.v`. The default `program.hex` exercises arithmetic, register writes, memory load/store, and control decode.

### QuestaSim

```text
vlog -sv tb_single_cycle.v *.v
vsim -c -do "run -all; quit" tb_single_cycle
```

### Icarus Verilog

```text
iverilog -g2012 -s tb_single_cycle -o riscv_core.out *.v
vvp riscv_core.out
```

## Project Files

- `single_cycle_top.v` - integrated datapath
- `main_decoder.v` - opcode control decoding
- `alu_decoder.v` - ALU operation decoding
- `alu.v` - RV32I arithmetic and logic operations
- `sign_extend.v` - I/S/B/U/J immediate generation
- `register_file.v` - 32-register bank
- `Instruction_memory.v` - hexadecimal instruction ROM
- `data_mem.v` - load/store data memory
- `PC.v`, `PC_Adder.v` - program-counter sequencing
