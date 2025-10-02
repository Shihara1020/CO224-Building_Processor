# CO224 Computer Architecture 🖥️

![Computer Architecture](https://img.shields.io/badge/Computer-Architecture-blue) 
![Verilog](https://img.shields.io/badge/Verilog-HDL-orange) 
![8-bit CPU](https://img.shields.io/badge/8-bit-CPU-green)

8-bit single-cycle processor implementation in Verilog HDL for CO224 Computer Architecture course at University of Peradeniya.

## Overview

This repository contains implementations for building a complete 8-bit processor from basic components to a full CPU with memory hierarchy.

## Components Implemented

### Part 1: ALU
- Basic arithmetic operations (ADD, SUB)
- Logic operations (AND, OR) 
- Data movement (MOV, LOADI)

### Part 2: Register File
- 8×8 register file
- Synchronous write, asynchronous read

### Part 3: Basic CPU
- Integrated ALU and register file
- Control unit implementation
- Program counter

### Part 4: Flow Control
- Jump instructions
- Branch instructions (BEQ)

### Part 5: Extended Instructions
- Multiplication, shift operations
- Additional instruction set

### Part 6: Memory Hierarchy
- **Part 6.1**: Data memory integration
- **Part 6.2**: Data cache implementation  
- **Part 6.3**: Instruction cache

## Repository Structure

```
Building_Processor/
├── Part1/          # ALU implementation
├── part2/          # Register file
├── part3/          # Basic CPU
├── part4/          # CPU with flow control
├── part5/          # Extended instruction set
├── part6_1/        # Data memory
├── part6_2/        # Data cache
└── part6_3/        # Instruction cache
```

## How to Run

1. Navigate to desired part directory
2. Compile with Icarus Verilog:
   ```bash
   iverilog -o output_file testbench.v module.v
   ```
3. Run simulation:
   ```bash
   vvp output_file
   ```
4. View waveforms:
   ```bash
   gtkwave waveform.vcd
   ```

## Tools Used

- **Verilog HDL** - Hardware description
- **Icarus Verilog** - Simulation 
- **GTKWave** - Waveform viewer

## Features

✅ Complete 8-bit processor  
✅ Assembly language support  
✅ Memory hierarchy with caching  
✅ Comprehensive testbenches  
✅ Waveform analysis
