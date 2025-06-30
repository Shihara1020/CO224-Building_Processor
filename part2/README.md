# Part 2: Register File Implementation

## Overview
This part implements and tests an 8-register file module for a CPU design. The register file is a crucial component that provides storage for 8 registers (R0-R7), each capable of storing 8-bit signed values, with dual read ports and a single write port.

## Project Structure
```
part2/
├── RegisterFile.v         # Main Verilog source file containing the register file module and testbench
├── README.md             # This documentation file
├── CPUtest.vvp          # Compiled Verilog executable
├── out.vvp              # Additional compiled output
├── task2.vcd            # Waveform data file generated during simulation
└── reg_file_wavedata.vcd # Additional waveform data
```

## Module Description

### Register File Module (`reg_file`)
- **Purpose**: 8-register file with dual read ports and single write port
- **Registers**: 8 registers (R0-R7), each storing 8-bit signed values
- **Features**:
  - Dual read ports for simultaneous reading from two different registers
  - Single write port for writing data to any register
  - Synchronous write operations (triggered on positive clock edge)
  - Asynchronous read operations (immediate output when address changes)
  - Reset functionality to clear all registers

#### Port Description
**Input Ports:**
- `OUT1ADDRESS [2:0]`: 3-bit address for first read port (selects R0-R7)
- `OUT2ADDRESS [2:0]`: 3-bit address for second read port (selects R0-R7)
- `INADDRESS [2:0]`: 3-bit address for write port (selects R0-R7)
- `IN [7:0]`: 8-bit signed data to write into selected register
- `CLK`: Clock signal for synchronous operations
- `RESET`: Reset signal (active high) - clears all registers
- `WRITE`: Write enable signal (active high)

**Output Ports:**
- `OUT1 [7:0]`: 8-bit signed data from first read port
- `OUT2 [7:0]`: 8-bit signed data from second read port

#### Key Features
1. **Synchronous Reset**: When RESET is high, all registers are cleared to 0
2. **Synchronous Write**: Data is written to the selected register on positive clock edge when WRITE is enabled
3. **Asynchronous Read**: Output values change immediately when read addresses change
4. **Timing Delays**: 
   - 1 time unit delay for reset and write operations
   - 2 time unit delay for read operations

## Testbench Features
The testbench (`reg_file_tb`) provides comprehensive testing of the register file:
- Tests reset functionality
- Tests write operations to different registers
- Tests read operations from multiple ports simultaneously
- Generates waveform data for GTKWave analysis
- Includes monitor statements to display register contents during simulation

## Compilation and Simulation

### Step 1: Compile the Verilog Code
```bash
iverilog -o CPUtest.vvp RegisterFile.v
```

### Step 2: Run the Simulation
```bash
vvp CPUtest.vvp
```

### Step 3: View Waveforms (Optional)
```bash
gtkwave task2.vcd
```

## Expected Output
The simulation will display:
- Time-stamped changes in register contents
- Test results showing write and read operations
- Register file behavior during reset operations

## Test Scenarios
The testbench covers the following scenarios:
1. **Reset Operation**: All registers cleared to 0
2. **Write Operations**: Writing different values to various registers
3. **Read Operations**: Reading from multiple registers simultaneously
4. **Edge Cases**: Testing with negative addresses and boundary conditions

## Implementation Details
- **Clock Period**: 8 time units (4 time units high, 4 time units low)
- **Reset Delay**: 1 time unit after positive clock edge
- **Write Delay**: 1 time unit after positive clock edge
- **Read Delay**: 2 time units for output stabilization

## Author
GROUP-06  
CO224 - Computer Architecture Lab  
Lab 05 - Part 2