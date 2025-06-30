# Part 5: CPU with Advanced Operations

## Overview
Part 5 significantly extends the CPU capabilities by implementing advanced arithmetic, logic, and control flow operations. This includes multiplication, various shift operations (logical left, arithmetic right, rotate right), and an additional branch instruction (BNE). The ALU is substantially enhanced with dedicated hardware modules for each new operation type.

## Project Structure
```
part5/
├── CPU.v                    # Enhanced CPU module with advanced operations
├── CPU_tb.v                 # CPU testbench with instruction memory
├── controlUnit.v            # Enhanced control unit supporting new instructions
├── PC.v                     # Enhanced PC with BNE branch support
├── RegisterFile.v           # 8-register file (unchanged)
├── MUX_2.v                  # 2-to-1 multiplexer module
├── instruction_memory.v     # Instruction decoder (unchanged)
├── twos_commplement.v       # Two's complement conversion module
├── CO224Assembler          # Assembler executable
├── CO224Assembler.c        # Assembler source code
├── generate_memory_image.sh # Memory image generation script
├── instr_mem.mem           # Generated memory image
├── cpu_wavedata.vcd        # Simulation waveform data
├── ALUSECTION/             # ALU component modules
│   ├── ALU.v               # Main ALU with 8 operations
│   ├── COMPENENT.v         # ALU support components
│   ├── multiplier.v        # 8-bit array multiplier
│   ├── logicalshift.v      # Logical shift left/right
│   └── rightshift.v        # Arithmetic/logical right shift
├── SampleProgram/          # Sample assembly programs
│   ├── MUL.s               # Multiplication test program
│   ├── BNE.s               # Branch not equal test program
│   ├── sll.s               # Shift left logical test
│   ├── srl.s               # Shift right logical test
│   ├── sra.s               # Shift right arithmetic test
│   └── ror.s               # Rotate right test
├── Waveform/               # Waveform configuration files
├── GTKWAVEFORM_SCREENSHOT/ # Waveform analysis images
├── DESIGNING/              # Design documentation
├── REPORT/                 # Project reports
└── README.md               # This documentation file
```

## New Features in Part 5

### 1. Advanced Arithmetic Operations
- **Multiplication (MULT)**: Hardware-based 8-bit × 8-bit array multiplier
- **Extended ALU**: 8 different operation modes with dedicated hardware

### 2. Shift and Rotate Operations
- **Shift Left Logical (SLL)**: Left shift with zero fill
- **Shift Right Arithmetic (SRA)**: Right shift with sign extension
- **Rotate Right (ROR)**: Circular right rotation preserving all bits

### 3. Enhanced Control Flow
- **Branch Not Equal (BNE)**: Conditional branch when operands are not equal
- **Improved PC Logic**: Support for both BEQ and BNE with unified branch controller

### 4. Modular ALU Architecture
- **Dedicated Operation Modules**: Separate hardware for each operation type
- **8×1 Multiplexer**: Selects appropriate operation result
- **Optimized Timing**: Different propagation delays for different operations

## Enhanced CPU Architecture

### ALU Operations Summary

| ALUOP | Operation | Module | Delay | Description |
|-------|-----------|--------|-------|-------------|
| 000 | FORWARD | - | 1 unit | Pass-through (MOV, LOADI) |
| 001 | ADD/SUB | Adder | 2 units | Addition/Subtraction with 2's complement |
| 010 | AND | Logic | 1 unit | Bitwise AND operation |
| 011 | OR | Logic | 1 unit | Bitwise OR operation |
| 100 | MULT | Multiplier | 3 units | 8-bit × 8-bit multiplication |
| 101 | SLL | Barrel Shifter | 2 units | Shift left logical (0-7 positions) |
| 110 | SRA | Barrel Shifter | 2 units | Shift right arithmetic (0-7 positions) |
| 111 | ROR | Barrel Shifter | 2 units | Rotate right (0-7 positions) |

### Enhanced Control Signals

#### Branch Control Enhancement
- **2-bit BRANCH Signal**: `[1:0] BRANCH`
  - `00`: Normal sequential execution
  - `01`: Unconditional jump (J)
  - `10`: Branch if equal (BEQ)
  - `11`: Branch if not equal (BNE)

#### PC Logic Enhancement
```verilog
// Branch decision logic
Branching = ZERO & BRANCH[1]
selector = BRANCH[0] ⊕ Branching

// PC selection
if (selector)
    PC = PC + 4 + (OFFSET << 2)
else
    PC = PC + 4
```

## Complete Instruction Set Architecture

### Instruction Format
All instructions maintain the same 32-bit format from previous parts:
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

### Complete ISA Table

| Instruction | Opcode | Format | Description | Example |
|-------------|--------|--------|-------------|---------|
| **Arithmetic Operations** |
| `ADD` | 00000000 | ADD RD,RS,RT | RD = RS + RT | `add 6 4 2` |
| `SUB` | 00000001 | SUB RD,RS,RT | RD = RS - RT | `sub 3 5 1` |
| **`MULT`** | **00001001** | **MULT RD,RS,RT** | **RD = RS × RT (lower 8 bits)** | **`mult 3 1 0`** |
| **Logical Operations** |
| `AND` | 00000010 | AND RD,RS,RT | RD = RS & RT | `and 2 4 5` |
| `OR` | 00000011 | OR RD,RS,RT | RD = RS \| RT | `or 1 3 7` |
| **Data Movement** |
| `MOV` | 00000100 | MOV RD,RS | RD = RS | `mov 0 6` |
| `LOADI` | 00000101 | LOADI RD,IMM | RD = IMM | `loadi 4 0x05` |
| **Shift Operations** |
| **`SLL`** | **00001010** | **SLL RD,RS,IMM** | **RD = RS << IMM** | **`sll 2 0 0x03`** |
| **`SRA`** | **00001100** | **SRA RD,RS,IMM** | **RD = RS >> IMM (arithmetic)** | **`sra 3 1 0x02`** |
| **`ROR`** | **00001101** | **ROR RD,RS,IMM** | **RD = RS rotate right IMM** | **`ror 2 0 0x03`** |
| **Control Flow** |
| `J` | 00000110 | J OFFSET | PC = PC + 4 + (OFFSET << 2) | `j 0xFD` |
| `BEQ` | 00000111 | BEQ OFFSET,RS,RT | if(RS==RT) PC = PC + 4 + (OFFSET << 2) | `beq 0x01 0 2` |
| **`BNE`** | **00001000** | **BNE OFFSET,RS,RT** | **if(RS≠RT) PC = PC + 4 + (OFFSET << 2)** | **`bne 0x02 0 1`** |

## Detailed Operation Analysis

### 1. Multiplication (MULT)
**Implementation**: 8-bit array multiplier using partial products
```verilog
// Hardware Implementation Features:
- Full parallel multiplication
- Carry-save addition for speed
- 16-bit intermediate result, 8-bit output (lower bits)
- 3 time unit propagation delay
```

**Example**: `mult 3 1 0` (R3 = R1 × R0)
- If R1 = 8, R0 = 9: R3 = 72 (0x48)
- If R1 = 12, R0 = 8: R3 = 96 (0x60)

### 2. Shift Left Logical (SLL)
**Implementation**: Barrel shifter with 3-stage multiplexer architecture
```verilog
// Features:
- Shift amounts: 0-7 positions
- Zero fill from right
- Amounts ≥8 result in all zeros
- 2 time unit propagation delay
```

**Example**: `sll 2 0 0x03` (R2 = R0 << 3)
- If R0 = 1 (0x01): R2 = 8 (0x08)
- If R0 = 8 (0x08): R2 = 64 (0x40)

### 3. Shift Right Arithmetic (SRA)
**Implementation**: Barrel shifter with sign extension
```verilog
// Features:
- Preserves sign bit (MSB)
- Sign extension from left
- Amounts ≥8 result in all 1s (negative) or all 0s (positive)
- 2 time unit propagation delay
```

**Example**: `sra 3 1 0x02` (R3 = R1 >> 2 arithmetic)
- If R1 = -8 (0xF8): R3 = -2 (0xFE)
- If R1 = 8 (0x08): R3 = 2 (0x02)

### 4. Rotate Right (ROR)
**Implementation**: Circular shifter preserving all bits
```verilog
// Features:
- Bits shifted out from right enter from left
- No data loss
- Effective rotate amount = amount mod 8
- 2 time unit propagation delay
```

**Example**: `ror 2 0 0x03` (R2 = R0 rotate right 3)
- If R0 = 0x01: R2 = 0x20 (bit 0 moves to bit 5)
- If R0 = 0xF1: R2 = 0x3E (lower 3 bits move to upper positions)

### 5. Branch Not Equal (BNE)
**Implementation**: Enhanced PC logic with XOR gate
```verilog
// Branch Logic:
1. ALU performs RS - RT (subtraction)
2. ZERO flag = 1 if RS == RT, 0 if RS ≠ RT
3. Branching = ZERO & BRANCH[1]
4. selector = BRANCH[0] ⊕ Branching
5. For BNE: BRANCH = 11, branch taken when ZERO = 0
```

**Example**: `bne 0x02 0 1` (if R0 ≠ R1, branch by offset 2)

## Sample Programs Analysis

### 1. Multiplication Test (`MUL.s`)
```assembly
loadi 0 0x08    // R0 = 8
loadi 1 0x09    // R1 = 9  
loadi 2 0x0C    // R2 = 12
mult 3 1 0      // R3 = R1 × R0 = 9 × 8 = 72
mult 4 0 0      // R4 = R0 × R0 = 8 × 8 = 64
mult 5 1 2      // R5 = R1 × R2 = 9 × 12 = 108
```

### 2. Shift Operations Test (`sll.s`)
```assembly
loadi 0 0x01    // R0 = 1
loadi 1 0x08    // R1 = 8
sll 2 0 0x03    // R2 = R0 << 3 = 1 << 3 = 8
sll 3 1 0x04    // R3 = R1 << 4 = 8 << 4 = 128 (0x80)
```

### 3. Branch Not Equal Test (`BNE.s`)
```assembly
loadi 0 0x03    // R0 = 3
loadi 1 0x05    // R1 = 5
bne 0x02 0 1    // if(R0 ≠ R1) branch by 2 instructions
sra 3 1 0x02    // Skipped if branch taken
loadi 3 0x10    // R3 = 16 (executed if branch taken)
loadi 4 0x10    // R4 = 16 (next instruction after branch)
```

## Build and Simulation Process

### Step 1: Select Sample Program
Choose from available sample programs:
- `MUL.s` - Multiplication operations
- `BNE.s` - Branch not equal testing
- `sll.s` - Shift left logical
- `srl.s` - Shift right logical  
- `sra.s` - Shift right arithmetic
- `ror.s` - Rotate right

### Step 2: Generate Memory Image
```bash
./generate_memory_image.sh SampleProgram/[program_name].s
```

### Step 3: Compile Verilog Design
```bash
iverilog -o CPUtest.vvp CPU_tb.v
```

### Step 4: Run Simulation
```bash
vvp CPUtest.vvp
```

### Step 5: View Waveforms
```bash
gtkwave cpu_wavedata.vcd Waveform/waveform.gtkw
```

## Performance Analysis

### Timing Characteristics
| Operation | Clock Cycles | ALU Delay | Description |
|-----------|--------------|-----------|-------------|
| ADD/SUB | 1 | 2 units | Arithmetic operations |
| AND/OR | 1 | 1 unit | Logical operations |
| MULT | 1 | 3 units | Multiplication (slowest) |
| Shifts/Rotate | 1 | 2 units | Barrel shifter operations |
| Branches | 1 | 2 units | Comparison + PC calculation |

### Critical Path Analysis
The multiplication operation now determines the maximum clock frequency due to its 3 time unit delay, making it the critical path in the processor.

## Enhanced ALU Architecture

### Modular Design Benefits
1. **Scalability**: Easy to add new operations
2. **Maintainability**: Each operation independently testable
3. **Performance**: Optimized timing for each operation type
4. **Reusability**: Modules can be reused in other designs

### Operation Selection Hierarchy
```
8×1 Multiplexer
├── 000: Forward (MOV, LOADI)
├── 001: Add/Subtract  
├── 010: AND
├── 011: OR
├── 100: Multiply
├── 101: Shift Left Logical
├── 110: Shift Right Arithmetic
└── 111: Rotate Right
```

## Testing and Verification

### Comprehensive Test Suite
1. **Arithmetic Tests**: ADD, SUB, MULT with various operands
2. **Logical Tests**: AND, OR with different bit patterns
3. **Shift Tests**: All shift types with various amounts
4. **Branch Tests**: BEQ and BNE with different conditions
5. **Control Flow Tests**: Complex programs with loops and conditionals

### Verification Methodology
1. **Unit Testing**: Each ALU operation tested independently
2. **Integration Testing**: Complete instruction execution
3. **Waveform Analysis**: Signal timing verification
4. **Functional Testing**: Real program execution
5. **Corner Case Testing**: Edge conditions and boundary values

## Applications and Use Cases

### Advanced Programming Constructs
```assembly
; Multiply by constant using shifts (faster than MULT)
; Multiply R0 by 5 = R0 * 4 + R0 = (R0 << 2) + R0
sll 1 0 0x02    ; R1 = R0 * 4
add 2 1 0       ; R2 = R1 + R0 = R0 * 5

; Fast division by 4 using arithmetic shift
sra 3 0 0x02    ; R3 = R0 / 4 (signed division)

; Efficient bit manipulation using rotates
ror 4 0 0x01    ; Rotate for bit testing
and 5 4 1       ; Extract rotated bit
```

### Algorithm Implementation
The enhanced instruction set enables implementation of:
- **Fast Arithmetic**: Efficient multiplication and division
- **Bit Manipulation**: Shift-based algorithms
- **Signal Processing**: Rotate operations for circular buffers
- **Conditional Logic**: More flexible branching

## Future Enhancements

### Potential Additions
1. **More Shift Types**: Logical right shift (SRL)
2. **Additional Branches**: BLT, BGT, BLE, BGE
3. **Data Memory**: Load/store instructions
4. **Advanced Arithmetic**: Division, remainder operations
5. **Floating Point**: IEEE 754 support

### Optimization Opportunities
1. **Pipeline**: Multi-stage pipeline for higher throughput
2. **Forwarding**: Data forwarding to reduce hazards
3. **Branch Prediction**: Dynamic branch prediction
4. **Cache**: Instruction and data caches

## Author
GROUP-06  
CO224 - Computer Architecture Lab  
Lab 05 - Part 5