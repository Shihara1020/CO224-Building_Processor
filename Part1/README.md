# Part 1: Arithmetic Logic Unit (ALU) Implementation

## Overview
This part implements a comprehensive Arithmetic Logic Unit (ALU) for a CPU design. The ALU is capable of performing multiple operations on 8-bit signed data including arithmetic, logical, and data forwarding operations. The design follows a modular approach with separate modules for each operation and a multiplexer for result selection.

## Project Structure
```
Part1/
├── ALU.v           # Main Verilog source file containing ALU modules and testbench
├── README.md       # This documentation file
├── out.vvp         # Compiled Verilog executable
└── part1.vcd       # Waveform data file generated during simulation
```

## ALU Architecture

### Main ALU Module (`alu`)
The ALU consists of:
- **Individual Operation Modules**: Separate modules for each operation (FORWARD, ADD, AND, OR)
- **4×1 Multiplexer**: Selects the appropriate operation result based on control signal
- **Modular Design**: Easy to extend with additional operations

#### Port Description
**Input Ports:**
- `DATA1 [7:0]`: First 8-bit signed operand
- `DATA2 [7:0]`: Second 8-bit signed operand  
- `SELECT [2:0]`: 3-bit operation selection signal

**Output Ports:**
- `RESULT [7:0]`: 8-bit signed result of the selected operation

## Supported Operations

### 1. FORWARD Operation (ALUOP = 000)
- **Function**: Passes DATA2 directly to the output
- **Usage**: Data movement and register-to-register transfers
- **Timing**: 1 time unit delay
- **Module**: `FORWARD`

### 2. ADD Operation (ALUOP = 001)
- **Function**: Performs signed addition (DATA1 + DATA2)
- **Usage**: Arithmetic calculations, address computation
- **Timing**: 2 time unit delay
- **Module**: `ADD`
- **Features**: Handles signed 8-bit arithmetic with overflow

### 3. AND Operation (ALUOP = 010)
- **Function**: Performs bitwise AND (DATA1 & DATA2)
- **Usage**: Bit masking, logical operations
- **Timing**: 1 time unit delay
- **Module**: `AND`

### 4. OR Operation (ALUOP = 011)
- **Function**: Performs bitwise OR (DATA1 | DATA2)
- **Usage**: Bit setting, logical operations
- **Timing**: 1 time unit delay
- **Module**: `OR`

## Operation Selection Table
| ALUOP | Operation | Description | Delay |
|-------|-----------|-------------|-------|
| 000   | FORWARD   | RESULT = DATA2 | 1 unit |
| 001   | ADD       | RESULT = DATA1 + DATA2 | 2 units |
| 010   | AND       | RESULT = DATA1 & DATA2 | 1 unit |
| 011   | OR        | RESULT = DATA1 \| DATA2 | 1 unit |
| 1xx   | RESERVED  | Future operations | - |

## Testbench Features
The comprehensive testbench (`testbench`) provides:
- **Operation Testing**: Tests all implemented ALU operations
- **Signed Data Handling**: Verifies correct signed arithmetic
- **Timing Verification**: Ensures proper operation delays
- **Waveform Generation**: Creates VCD files for GTKWave analysis
- **Real-time Monitoring**: Displays results with timestamps

### Test Cases
1. **FORWARD Test**: 
   - OPERAND1 = 0, OPERAND2 = 65, ALUOP = 000
   - Expected: RESULT = 65

2. **ADD Test**: 
   - OPERAND1 = 45, OPERAND2 = 30, ALUOP = 001
   - Expected: RESULT = 75

3. **AND Test**: 
   - OPERAND1 = 0b00100110 (38), OPERAND2 = 0b00111010 (58), ALUOP = 010
   - Expected: RESULT = 0b00100010 (34)

4. **OR Test**: 
   - Same operands as AND test, ALUOP = 011
   - Expected: RESULT = 0b00111110 (62)

## Compilation and Simulation

### Step 1: Compile the Verilog Code
```bash
iverilog -o CPUtest.vvp ALU.v
```

### Step 2: Run the Simulation
```bash
vvp CPUtest.vvp
```

### Step 3: View Waveforms (Optional)
```bash
gtkwave part1.vcd
```

## Expected Output Format
The simulation displays results in the following format:
```
TIME=<time> : OP1:<operand1> OP2:<operand2> ALUOP:<operation> RESULT:<result>(<binary>)
```

Example:
```
TIME=0 : OP1:0 OP2:65 ALUOP:000 RESULT:65(01000001)
TIME=10 : OP1:45 OP2:30 ALUOP:001 RESULT:75(01001011)
```

## Implementation Details

### Timing Characteristics
- **FORWARD Operation**: 1 time unit propagation delay
- **ADD Operation**: 2 time units propagation delay (most complex)
- **AND/OR Operations**: 1 time unit propagation delay each
- **Test Intervals**: 10 time units between test cases

### Design Features
- **Signed Arithmetic**: All operations handle 8-bit signed two's complement numbers
- **Modular Architecture**: Each operation implemented as separate module
- **Extensible Design**: Easy to add more operations (4 reserved opcodes available)
- **Concurrent Operations**: All operation modules compute results simultaneously
- **Multiplexed Output**: Final result selected based on ALUOP control signal

### Key Advantages
1. **Modularity**: Each operation can be tested and modified independently
2. **Scalability**: Easy to extend with additional operations
3. **Performance**: Parallel computation of all operations
4. **Testability**: Comprehensive testbench with multiple test cases
5. **Documentation**: Well-commented code for maintainability

## Future Enhancements
The design reserves 4 additional operation codes (100-111) for future operations such as:
- Subtraction (SUB)
- Shift operations (SLL, SRL, SRA)
- Comparison operations (SLT)
- XOR operation

## Author
GROUP-06  
CO224 - Computer Architecture Lab  
Lab 05 - Part 1