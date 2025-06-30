# Part 3: Single-Cycle CPU Implementation

## Overview
This part implements a complete single-cycle processor capable of executing a basic instruction set. The CPU integrates all previously developed components (ALU from Part 1, Register File from Part 2) along with new components including Program Counter, Control Unit, Instruction Memory, and Multiplexers to create a functional processor.

## Project Structure
```
part3/
├── CPU.v                    # Main CPU module integrating all components
├── CPU_tb.v                 # CPU testbench with instruction memory
├── ALU.v                    # Arithmetic Logic Unit (from Part 1)
├── RegisterFile.v           # 8-register file (from Part 2)
├── controlUnit.v            # Control unit for instruction decode
├── PC.v                     # Program counter module
├── MUX_2.v                  # 2-to-1 multiplexer module
├── instruction_memory.v     # Instruction memory interface
├── twos_commplement.v       # Two's complement conversion module
├── sample_program.s         # Sample assembly program
├── sample_program.s.machine # Machine code version of sample program
├── CO224Assembler          # Assembler executable
├── CO224Assembler.c        # Assembler source code
├── generate_memory_image.sh # Script to generate memory image
├── instr_mem.mem           # Memory image file (binary format)
├── CPU-Part3.pdf           # CPU architecture diagram
├── CPU-Part3.jpg           # CPU block diagram image
├── cpu_wavedata.vcd        # Simulation waveform data
└── README.md               # This documentation file
```

## CPU Architecture

### Single-Cycle Processor Design
The CPU implements a classic single-cycle architecture where each instruction completes in one clock cycle. The processor features:

- **Data Width**: 8-bit data processing
- **Instruction Width**: 32-bit instructions
- **Address Width**: 32-bit program counter and addresses
- **Register File**: 8 registers (R0-R7), each 8-bit
- **Pipeline**: Single-cycle (no pipelining)

### CPU Components Integration

#### 1. Program Counter (PC)
- **Function**: Generates sequential instruction addresses
- **Width**: 32-bit addressing
- **Increment**: +4 per cycle (word-aligned)
- **Reset**: Initializes to address 0

#### 2. Instruction Memory
- **Capacity**: 1024 bytes (256 32-bit instructions)
- **Access**: 2 time unit fetch delay
- **Format**: Little-endian byte organization
- **Loading**: Supports both manual and file-based loading

#### 3. Instruction Decoder
- **Input**: 32-bit instruction
- **Output**: Component fields (OPCODE, RD, RT, RS, IMMEDIATE)
- **Format**: `[31:24]OPCODE [23:21]RD [20:18]RT [17:15]RS [14:7]UNUSED [6:0]IMMEDIATE`

#### 4. Control Unit
- **Input**: 8-bit OPCODE
- **Outputs**: WRITEENABLE, ALUSRC, ALUOP, NEMUX
- **Function**: Generates control signals for datapath
- **Delay**: 1 time unit

#### 5. Register File (from Part 2)
- **Registers**: 8 × 8-bit signed registers (R0-R7)
- **Ports**: Dual read, single write
- **Access**: Asynchronous read, synchronous write

#### 6. ALU (from Part 1)
- **Operations**: ADD, SUB, AND, OR, MOV, LOADI
- **Width**: 8-bit signed arithmetic
- **Control**: 3-bit ALUOP selection

#### 7. Supporting Components
- **Two's Complement Unit**: Enables subtraction via addition
- **Multiplexers**: Data path selection and control

## Supported Instruction Set

### Instruction Format
```
31    24 23  21 20  18 17  15 14   7 6    0
+--------+------+------+------+------+------+
| OPCODE |  RD  |  RT  |  RS  |UNUSED| IMM  |
+--------+------+------+------+------+------+
```

### Instruction Set Architecture (ISA)

| Instruction | Opcode | Format | Description | Example |
|-------------|--------|--------|-------------|---------|
| `ADD` | 00000000 | ADD RD,RS,RT | RD = RS + RT | `add 6 4 2` |
| `SUB` | 00000001 | SUB RD,RS,RT | RD = RS - RT | `sub 3 5 1` |
| `AND` | 00000010 | AND RD,RS,RT | RD = RS & RT | `and 2 4 5` |
| `OR` | 00000011 | OR RD,RS,RT | RD = RS \| RT | `or 1 3 7` |
| `MOV` | 00000100 | MOV RD,RS | RD = RS | `mov 0 6` |
| `LOADI` | 00000101 | LOADI RD,IMM | RD = IMM | `loadi 4 0x05` |

### Control Signal Generation

| Instruction | WRITEENABLE | ALUOP | ALUSRC | NEMUX | Description |
|-------------|-------------|-------|--------|-------|-------------|
| ADD | 1 | 001 | 1 | 0 | Register write, addition, use registers |
| SUB | 1 | 001 | 1 | 1 | Register write, addition with negation |
| AND | 1 | 010 | 1 | 0 | Register write, AND operation |
| OR | 1 | 011 | 1 | 0 | Register write, OR operation |
| MOV | 1 | 000 | 1 | 0 | Register write, forward data |
| LOADI | 1 | 000 | 0 | 0 | Register write, use immediate |

## Datapath Flow

1. **Instruction Fetch**: PC provides address to instruction memory
2. **Instruction Decode**: 32-bit instruction broken into fields
3. **Control Generation**: Control unit produces control signals
4. **Register Read**: Source registers read from register file
5. **ALU Operation**: Arithmetic/logic operation performed
6. **Result Write**: Result written back to destination register
7. **PC Update**: Program counter incremented for next instruction

## Sample Program Analysis

### Assembly Code (`sample_program.s`)
```assembly
loadi 4 0x05    // R4 = 5
loadi 2 0x09    // R2 = 9  
add 6 4 2       // R6 = R4 + R2 = 5 + 9 = 14
mov 0 6         // R0 = R6 = 14
loadi 1 0x01    // R1 = 1
add 2 2 1       // R2 = R2 + R1 = 9 + 1 = 10
```

### Expected Results
- R0 = 14 (result of 5 + 9)
- R1 = 1 (immediate value)
- R2 = 10 (9 + 1)
- R4 = 5 (immediate value)
- R6 = 14 (5 + 9)

## Build and Simulation Process

### Step 1: Generate Memory Image
```bash
./generate_memory_image.sh sample_program.s
```
This step:
- Compiles the assembly program using CO224Assembler
- Generates `sample_program.s.machine` (human-readable machine code)
- Creates `instr_mem.mem` (binary memory image)

### Step 2: Compile Verilog Design
```bash
iverilog -o CPUtest.vvp CPU_tb.v
```

### Step 3: Run Simulation
```bash
vvp CPUtest.vvp
```

### Step 4: View Waveforms (Optional)
```bash
gtkwave cpu_wavedata.vcd
```

## File Dependencies

### Include Hierarchy
```
CPU_tb.v
└── CPU.v
    ├── twos_commplement.v
    ├── RegisterFile.v
    ├── PC.v
    ├── MUX_2.v
    ├── instruction_memory.v
    ├── controlUnit.v
    └── ALU.v
```

## Testing and Verification

### Testbench Features
- **Instruction Loading**: Supports both manual and file-based instruction loading
- **Clock Generation**: Configurable clock period
- **Reset Testing**: Verifies proper initialization
- **Waveform Generation**: Creates VCD files for analysis
- **Memory Interface**: 1024-byte instruction memory simulation

### Verification Points
1. **Instruction Fetch**: Correct instruction retrieval from memory
2. **Instruction Decode**: Proper field extraction
3. **Control Signal Generation**: Correct control signals for each instruction
4. **Register Operations**: Read/write functionality
5. **ALU Operations**: All arithmetic and logic operations
6. **Data Path**: End-to-end instruction execution

## Design Features

### Key Advantages
1. **Modular Design**: Each component independently testable
2. **Single-Cycle**: Simple timing model, easy to understand
3. **Extensible**: Easy to add new instructions
4. **Well-Documented**: Comprehensive comments and documentation
5. **Industry Standard**: Follows classic RISC design principles

### Performance Characteristics
- **Clock Period**: Determined by longest propagation path
- **Instructions Per Clock**: 1 (single-cycle)
- **Memory Latency**: 2 time units for instruction fetch
- **ALU Latency**: 1-2 time units depending on operation

## Limitations and Future Enhancements

### Current Limitations
- No data memory (load/store instructions)
- No branch/jump instructions
- No interrupt handling
- Single-cycle only (no pipelining)

### Potential Enhancements
- Add data memory and load/store instructions
- Implement branch and jump instructions
- Add pipeline stages for higher performance
- Include exception handling
- Expand instruction set (shifts, multiplication, etc.)

## Author
GROUP-06  
Dewagedara D.M.E.S. / PERERA W.S.S.  
CO224 - Computer Architecture Lab  
Lab 05 - Part 3