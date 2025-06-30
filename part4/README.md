# Part 4: CPU with Branch and Jump Instructions

## Overview
Part 4 extends the single-cycle CPU from Part 3 by adding support for control flow instructions including branching and jumping. This enhancement transforms the processor from a simple arithmetic machine into a more complete processor capable of implementing loops, conditionals, and program flow control.

## Project Structure
```
part4/
├── CPU.v                    # Enhanced CPU module with branch/jump support
├── CPU_tb.v                 # CPU testbench with instruction memory
├── ALU.v                    # Enhanced ALU with ZERO flag output
├── RegisterFile.v           # 8-register file (unchanged from Part 2)
├── controlUnit.v            # Enhanced control unit with branch/jump controls
├── PC.v                     # Enhanced program counter with branch/jump logic
├── MUX_2.v                  # 2-to-1 multiplexer module
├── instruction_memory.v     # Enhanced instruction decoder with OFFSET field
├── twos_commplement.v       # Two's complement conversion module
├── sample_program.s         # Sample assembly program with branches
├── sample_program.s.machine # Machine code version
├── CO224Assembler          # Assembler executable
├── CO224Assembler.c        # Assembler source code
├── generate_memory_image.sh # Script to generate memory image
├── instr_mem.mem           # Memory image file (binary format)
├── cpu_wavedata.vcd        # Simulation waveform data
├── BLOCK DIGRAM/           # Block diagrams and documentation
├── DOCx/                   # Additional documentation
├── ExplanationWithWaveform/ # Waveform analysis
├── Wavefoorm/              # Waveform files
├── WaveformIMG/            # Waveform screenshots
└── README.md               # This documentation file
```

## New Features in Part 4

### 1. Branch Instructions
- **Conditional Branching**: Branch based on comparison results
- **Zero Flag**: ALU generates ZERO flag for comparison operations
- **Relative Addressing**: PC-relative branch target calculation

### 2. Jump Instructions
- **Unconditional Jumps**: Direct program flow control
- **Absolute/Relative Addressing**: Support for various jump modes

### 3. Enhanced Program Counter
- **Branch Logic**: Conditional PC update based on branch conditions
- **Jump Logic**: Unconditional PC update for jump instructions
- **Target Calculation**: Automatic branch/jump target address computation

## Enhanced CPU Architecture

### Modified Components

#### 1. Program Counter (PC) - Enhanced
- **New Inputs**: BRANCH, ZERO, JUMP, OFFSET
- **Branch Logic**: PC = PC + 4 + (OFFSET << 2) when branch taken
- **Jump Logic**: PC = PC + 4 + (OFFSET << 2) when jump executed
- **Sequential Logic**: PC = PC + 4 for normal instructions

#### 2. ALU - Enhanced  
- **New Output**: ZERO flag indicates if result equals zero
- **Comparison Support**: Enables branch condition evaluation
- **Same Operations**: All arithmetic/logic operations from Part 3

#### 3. Control Unit - Enhanced
- **New Outputs**: BRANCH, JUMP control signals
- **Extended Opcodes**: Support for BEQ and J instructions
- **Branch Control**: Coordinates ALU comparison with PC logic

#### 4. Instruction Decoder - Enhanced
- **New Output**: OFFSET field for branch/jump targets
- **Updated Format**: Modified instruction layout for control flow

### Enhanced Datapath Flow

1. **Instruction Fetch**: PC provides address to instruction memory
2. **Instruction Decode**: Extract OPCODE, registers, IMMEDIATE, and OFFSET
3. **Control Generation**: Generate control signals including BRANCH/JUMP
4. **Register Read**: Read source registers for operations/comparisons
5. **ALU Operation**: Perform operation and generate ZERO flag
6. **Branch/Jump Logic**: Calculate target address if needed
7. **PC Update**: Update PC based on instruction type
8. **Result Write**: Write ALU result to register (if applicable)

## Enhanced Instruction Set

### New Instruction Format
```
31    24 23    16 15    11 10     8 7      3 2     0
+--------+--------+--------+--------+--------+-------+
| OPCODE | OFFSET | UNUSED | READREG1| UNUSED |READREG2|
+--------+--------+--------+--------+--------+-------+
        Branch/Jump Instructions

31    24 23  21 20  18 17  15 14   7 6    0
+--------+------+------+------+------+------+
| OPCODE |  RD  |  RT  |  RS  |UNUSED| IMM  |
+--------+------+------+------+------+------+
        Regular Instructions
```

### Complete Instruction Set

| Instruction | Opcode | Format | Description | Example |
|-------------|--------|--------|-------------|---------|
| `ADD` | 00000000 | ADD RD,RS,RT | RD = RS + RT | `add 6 4 2` |
| `SUB` | 00000001 | SUB RD,RS,RT | RD = RS - RT | `sub 3 5 1` |
| `AND` | 00000010 | AND RD,RS,RT | RD = RS & RT | `and 2 4 5` |
| `OR` | 00000011 | OR RD,RS,RT | RD = RS \| RT | `or 1 3 7` |
| `MOV` | 00000100 | MOV RD,RS | RD = RS | `mov 0 6` |
| `LOADI` | 00000101 | LOADI RD,IMM | RD = IMM | `loadi 4 0x05` |
| **`J`** | **00000110** | **J OFFSET** | **PC = PC + 4 + (OFFSET << 2)** | **`j 0xFD`** |
| **`BEQ`** | **00000111** | **BEQ OFFSET,RS,RT** | **if(RS==RT) PC = PC + 4 + (OFFSET << 2)** | **`beq 0x01 0 2`** |

### Control Signal Generation

| Instruction | WRITEENABLE | ALUOP | ALUSRC | NEMUX | BRANCH | JUMP |
|-------------|-------------|-------|--------|-------|--------|------|
| ADD | 1 | 001 | 1 | 0 | 0 | 0 |
| SUB | 1 | 001 | 1 | 1 | 0 | 0 |
| AND | 1 | 010 | 1 | 0 | 0 | 0 |
| OR | 1 | 011 | 1 | 0 | 0 | 0 |
| MOV | 1 | 000 | 1 | 0 | 0 | 0 |
| LOADI | 1 | 000 | 0 | 0 | 0 | 0 |
| **J** | **0** | **000** | **0** | **0** | **0** | **1** |
| **BEQ** | **0** | **001** | **1** | **1** | **1** | **0** |

## Branch and Jump Mechanics

### Branch Execution (BEQ)
1. **Comparison**: ALU performs RS - RT (subtraction)
2. **Zero Flag**: ZERO = 1 if RS == RT, else ZERO = 0
3. **Branch Decision**: Take branch if ZERO = 1 and BRANCH = 1
4. **Target Calculation**: PC = PC + 4 + (OFFSET << 2)
5. **PC Update**: Update PC with target or PC + 4

### Jump Execution (J)
1. **Unconditional**: Always executed regardless of conditions
2. **Target Calculation**: PC = PC + 4 + (OFFSET << 2)
3. **PC Update**: Update PC with calculated target address

### Address Calculation
- **Offset Extension**: 8-bit OFFSET sign-extended to 32-bit
- **Word Alignment**: Left shift by 2 bits (×4) for word addressing
- **Relative Addressing**: Target = PC + 4 + Extended_Offset

## Sample Program Analysis

### Assembly Code (`sample_program.s`)
```assembly
loadi 0 0x06    // R0 = 6
loadi 1 0x01    // R1 = 1  
loadi 2 0x03    // R2 = 3
loadi 3 0x08    // R3 = 8
sub 0 0 1       // R0 = R0 - R1 = 6 - 1 = 5
beq 0x01 0 2    // if(R0 == R2) PC = PC + 4 + (1 << 2) = PC + 8
j 0xFD          // PC = PC + 4 + (-3 << 2) = PC - 8 (loop back)
add 4 0 3       // R4 = R0 + R3 = 5 + 8 = 13 (if branch taken)
```

### Program Flow Analysis
1. **Initialization**: Load immediate values into R0-R3
2. **Arithmetic**: Subtract R1 from R0 (6-1=5)
3. **Comparison**: Compare R0(5) with R2(3) - not equal
4. **Branch**: Branch not taken (5 ≠ 3)
5. **Jump**: Unconditional jump back by 3 instructions
6. **Loop**: Creates infinite loop until R0 equals R2

### Expected Execution Trace
```
PC=0: loadi 0 0x06  → R0=6
PC=4: loadi 1 0x01  → R1=1
PC=8: loadi 2 0x03  → R2=3
PC=12: loadi 3 0x08 → R3=8
PC=16: sub 0 0 1    → R0=5, ZERO=0
PC=20: beq 0x01 0 2 → R0≠R2, branch not taken
PC=24: j 0xFD       → PC = 24+4+(-3*4) = 16 (loop)
```

## Build and Simulation Process

### Step 1: Generate Memory Image
```bash
./generate_memory_image.sh sample_program.s
```

### Step 2: Compile Verilog Design  
```bash
iverilog -o CPUtest.vvp CPU_tb.v
```

### Step 3: Run Simulation
```bash
vvp CPUtest.vvp
```

### Step 4: View Waveforms
```bash
gtkwave cpu_wavedata.vcd
```

## Key Waveform Signals

### Critical Signals to Monitor
- **PC**: Program counter progression
- **INSTRUCTION**: Current instruction being executed
- **ZERO**: ALU zero flag for branch decisions
- **BRANCH**: Branch control signal
- **JUMP**: Jump control signal
- **OFFSET**: Branch/jump target offset
- **Register Contents**: Register file state changes

## Testing and Verification

### Test Scenarios
1. **Sequential Execution**: Normal instruction flow
2. **Branch Taken**: Conditional branch when condition is true
3. **Branch Not Taken**: Conditional branch when condition is false
4. **Unconditional Jump**: Jump instruction execution
5. **Loop Execution**: Programs with iterative behavior

### Verification Points
1. **PC Calculation**: Correct next PC for all instruction types
2. **Branch Logic**: Proper branch decision based on ZERO flag
3. **Target Addressing**: Accurate branch/jump target calculation
4. **Control Flow**: Correct program execution sequence
5. **Register Updates**: Proper register file modifications

## Design Enhancements from Part 3

### Major Additions
1. **ZERO Flag Generation**: ALU now outputs comparison result
2. **Branch/Jump Control**: New control signals for flow control
3. **PC Logic**: Enhanced program counter with target calculation
4. **Instruction Format**: Extended decoder for OFFSET field
5. **Control Flow**: Support for loops and conditional execution

### Performance Implications
- **Single-Cycle**: All instructions still complete in one cycle
- **Branch Penalty**: No branch delay slots (single-cycle design)
- **Jump Latency**: Immediate jump execution
- **Loop Efficiency**: Efficient iterative program execution

## Applications and Use Cases

### Programming Constructs Supported
1. **Conditional Statements**: if-else logic using BEQ
2. **Loops**: while/for loops using BEQ + J combinations
3. **Function Calls**: Basic subroutine jumps
4. **Program Flow**: Complex control flow patterns

### Example Programming Patterns
```assembly
; Countdown loop
loadi 0 10          ; counter = 10
loop:
    sub 0 0 1       ; counter--
    beq end 0 0     ; if counter == 0 goto end
    j loop          ; goto loop
end:
    ; program continues
```

## Limitations and Future Work

### Current Limitations
- **No Data Memory**: Still no load/store instructions
- **Limited Branch Types**: Only equality comparison
- **No Stack**: No subroutine call/return mechanism
- **Simple Addressing**: Only PC-relative addressing

### Future Enhancements
- **More Branch Types**: BNE, BLT, BGT instructions
- **Data Memory**: Load/store instruction support
- **Function Calls**: JAL/JR for subroutines
- **Exception Handling**: Interrupt and exception support
- **Pipeline**: Multi-stage pipeline for performance

## Author
GROUP-06  
CO224 - Computer Architecture Lab  
Lab 05 - Part 4