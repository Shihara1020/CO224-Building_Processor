
# Part 6_1: CPU with Data Memory Implementation

## Overview
Part 6_1 introduces data memory capabilities to the CPU, transforming it from a compute-only processor to a complete system capable of loading and storing data in memory. This implementation adds four new load/store instructions and integrates a 256-byte data memory module with the existing CPU architecture.

## Project Structure
```
part6_1/
├── CPU.v                    # Enhanced CPU with data memory interface
├── CPU_tb.v                 # CPU testbench with data memory integration
├── DataMemory.v             # 256×8-bit data memory module
├── controlUnit.v            # Enhanced control unit with memory operations
├── PC.v                     # Program counter (unchanged)
├── RegisterFile.v           # 8-register file (unchanged)
├── MUX_2.v                  # 2-to-1 multiplexer module
├── instruction_memory.v     # Instruction decoder (unchanged)
├── twos_commplement.v       # Two's complement module (unchanged)
├── ALUSECTION/             # ALU modules (unchanged from Part 5)
├── SAMPLEPROGRAM.s         # Sample program with load/store operations
├── SAMPLEPROGRAM.s.machine # Machine code version
├── SAMPLEPROGRAM2.s        # Alternative sample program
├── SAMPLEPROGRAM2.s.machine# Machine code version
├── WAVEFORM.gtkw           # Waveform configuration file
├── WAVEFORM/               # Waveform analysis files
├── REPORT/                 # Documentation and reports
└── README.md               # This documentation file
```

## Data Memory Architecture

### Memory Specifications
- **Capacity**: 256 bytes (256 × 8-bit words)
- **Organization**: Byte-addressable memory
- **Address Range**: 0x00 to 0xFF (8-bit addressing)
- **Data Width**: 8-bit read/write operations
- **Access Type**: Synchronous read/write with busy-wait protocol

### Data Memory Module Features

#### 1. Memory Array
```verilog
reg [7:0] memory_array [255:0];  // 256×8-bit memory array
```

#### 2. Control Signals
- **`read`**: Memory read enable signal
- **`write`**: Memory write enable signal  
- **`address[7:0]`**: 8-bit memory address
- **`writedata[7:0]`**: 8-bit data to write
- **`readdata[7:0]`**: 8-bit data read from memory
- **`busywait`**: Memory busy signal (high during access)

#### 3. Timing Characteristics
- **Access Latency**: 40 time units for both read and write
- **Busy-Wait Protocol**: CPU stalls during memory operations
- **Reset Behavior**: All memory locations cleared to 0

### Memory Access Protocol

#### Read Operation Sequence
1. **Request Phase**: CPU asserts `read = 1` with valid address
2. **Busy Phase**: Memory asserts `busywait = 1` immediately
3. **Access Phase**: Memory performs read operation (40 time units)
4. **Complete Phase**: Memory provides `readdata` and clears `busywait`
5. **Release Phase**: CPU deasserts `read`, operation complete

#### Write Operation Sequence
1. **Request Phase**: CPU asserts `write = 1` with address and data
2. **Busy Phase**: Memory asserts `busywait = 1` immediately
3. **Access Phase**: Memory performs write operation (40 time units)
4. **Complete Phase**: Memory stores data and clears `busywait`
5. **Release Phase**: CPU deasserts `write`, operation complete

## Load/Store Instruction Set

### New Instructions Added

| Instruction | Opcode | Format | Description | Example |
|-------------|--------|--------|-------------|---------|
| **`LWD`** | 00001110 | LWD RD,RS,RT | Load: RD = MEM[RS + RT] | `lwd 3 1 0` |
| **`LWI`** | 00001111 | LWI RD,RS,IMM | Load: RD = MEM[RS + IMM] | `lwi 4 0 0x02` |
| **`SWD`** | 00010000 | SWD RS,RT,RU | Store: MEM[RT + RU] = RS | `swd 0 1 0` |
| **`SWI`** | 00010001 | SWI RS,RT,IMM | Store: MEM[RT + IMM] = RS | `swi 2 0 0x02` |

### Addressing Modes

#### 1. Register + Register Addressing (LWD, SWD)
- **Address Calculation**: `Address = Register1 + Register2`
- **Use Case**: Dynamic addressing with base + offset
- **Example**: `lwd 3 1 0` → Address = R1 + R0

#### 2. Register + Immediate Addressing (LWI, SWI)
- **Address Calculation**: `Address = Register + Immediate`
- **Use Case**: Static addressing with base + constant offset
- **Example**: `lwi 4 0 0x02` → Address = R0 + 2

### Instruction Implementation Details

#### Load Word Direct (LWD)
```assembly
lwd RD, RS, RT    # RD = MEM[RS + RT]
```
**Operation Flow:**
1. ALU calculates address: `Address = RS + RT`
2. Memory read initiated with calculated address
3. CPU waits for `busywait` to clear
4. Memory data written to destination register RD

#### Load Word Immediate (LWI)
```assembly
lwi RD, RS, IMM   # RD = MEM[RS + IMM]
```
**Operation Flow:**
1. ALU calculates address: `Address = RS + IMM`
2. Memory read initiated with calculated address
3. CPU waits for `busywait` to clear
4. Memory data written to destination register RD

#### Store Word Direct (SWD)
```assembly
swd RS, RT, RU    # MEM[RT + RU] = RS
```
**Operation Flow:**
1. ALU calculates address: `Address = RT + RU`
2. Memory write initiated with RS data to calculated address
3. CPU waits for `busywait` to clear
4. No register write (WRITEENABLE = 0)

#### Store Word Immediate (SWI)
```assembly
swi RS, RT, IMM   # MEM[RT + IMM] = RS
```
**Operation Flow:**
1. ALU calculates address: `Address = RT + IMM`
2. Memory write initiated with RS data to calculated address
3. CPU waits for `busywait` to clear
4. No register write (WRITEENABLE = 0)

## Enhanced CPU Datapath

### New Datapath Components

#### 1. Data Memory Interface
- **Address Bus**: ALU output drives memory address
- **Write Data Bus**: REGOUT1 drives memory write data
- **Read Data Bus**: Memory read data input to CPU
- **Control Signals**: READ, WRITE, BUSYWAIT

#### 2. Write Data Source Multiplexer
```verilog
mux_unit writedataSelector(ALUOUTPUT, READDATA, WRITESRC, REGWRITEDATA);
```
- **WRITESRC = 0**: Register write data comes from ALU result
- **WRITESRC = 1**: Register write data comes from memory read data

#### 3. CPU Stall Logic
```verilog
// PC hold during memory operations
pc_unit PCUNIT(RESET, CLK, PC, BRANCH, ZERO, OFFSET, HOLD);

// Control unit generates HOLD signal
always @(BUSYWAIT) begin
    HOLD = BUSYWAIT;
end
```

### Enhanced Control Signals

| Signal | Purpose | Load Instructions | Store Instructions |
|--------|---------|-------------------|-------------------|
| READ | Memory read enable | 1 | 0 |
| WRITE | Memory write enable | 0 | 1 |
| WRITESRC | Register write source | 1 (memory) | 0 (ALU) |
| WRITEENABLE | Register write enable | 1 | 0 |
| HOLD | CPU stall signal | BUSYWAIT | BUSYWAIT |

## Sample Program Analysis

### Sample Program 1 (`SAMPLEPROGRAM.s`)
```assembly
loadi 0 0x0B    # R0 = 11 (base address)
loadi 1 0x01    # R1 = 1 (offset)
loadi 2 0x05    # R2 = 5 (data to store)
swd 0 1         # MEM[R1 + R0] = R0 → MEM[12] = 11
swi 2 0x02      # MEM[R0 + 2] = R2 → MEM[13] = 5
lwd 3 1         # R3 = MEM[R1 + R0] → R3 = MEM[12] = 11
```

**Memory Layout After Execution:**
```
Address | Data | Source
--------|------|--------
0x0C    | 0x0B | swd 0 1 (R0 stored at address R1+R0=12)
0x0D    | 0x05 | swi 2 0x02 (R2 stored at address R0+2=13)
Others  | 0x00 | Initial state
```

**Register State After Execution:**
```
R0 = 0x0B (11)
R1 = 0x01 (1)
R2 = 0x05 (5)
R3 = 0x0B (11) - loaded from memory[12]
```

### Sample Program 2 (`SAMPLEPROGRAM2.s`)
```assembly
loadi 0 0x0B    # R0 = 11
loadi 1 0x01    # R1 = 1
loadi 2 0x05    # R2 = 5
swd 0 1         # MEM[12] = 11
swi 2 0x02      # MEM[13] = 5
lwi 4 0x02      # R4 = MEM[R0 + 2] → R4 = MEM[13] = 5
```

**Key Difference:** Uses `lwi` instead of `lwd` to load from immediate offset.

## Memory Access Timing Analysis

### Single Memory Operation Timing
```
Clock Cycle: 1    2    3    ...  42   43
CPU State:   Exec Wait Wait ... Wait Resume
BUSYWAIT:    0    1    1    ... 1    0
Memory:      Idle Busy Busy ... Busy Ready
```

### Memory Operation Performance Impact
- **Without Memory**: 1 clock cycle per instruction
- **With Memory Load**: 1 + 40 = 41 clock cycles total
- **With Memory Store**: 1 + 40 = 41 clock cycles total
- **Performance Cost**: 40× slower for memory operations

## CPU Stall Mechanism

### PC Hold Logic
```verilog
// PC is held constant during memory operations
if (HOLD == 1) begin
    PC <= PC;  // No increment
end else begin
    PC <= nextPC;  // Normal increment or branch
end
```

### Control Unit Stall Logic
```verilog
always @(BUSYWAIT) begin
    HOLD = BUSYWAIT;
    if (BUSYWAIT == 0) begin
        READ = 0;
        write = 0;
    end
end
```

## Build and Simulation Process

### Step 1: Generate Memory Image
```bash
./generate_memory_image.sh SAMPLEPROGRAM.s
```

### Step 2: Compile Design
```bash
iverilog -o CPUtest.vvp CPU_tb.v
```

### Step 3: Run Simulation
```bash
vvp CPUtest.vvp
```

### Step 4: Analyze Waveforms
```bash
gtkwave cpu_wavedata.vcd WAVEFORM.gtkw
```

## Key Waveform Signals for Memory Operations

### Critical Signals to Monitor
- **ADDRESS[7:0]**: Memory address bus
- **WRITEDATA[7:0]**: Data being written to memory
- **READDATA[7:0]**: Data being read from memory
- **READ**: Memory read enable
- **WRITE**: Memory write enable
- **BUSYWAIT**: Memory busy signal
- **HOLD**: CPU stall signal
- **PC**: Program counter (should hold during memory access)

### Memory Operation Waveform Pattern
```
READ     : ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____
BUSYWAIT : ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____
HOLD     : ____/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____
PC       : ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
READDATA : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx<VALID>xxxx
```

## Design Features and Benefits

### Memory Hierarchy Foundation
- **Separation of Concerns**: Instruction and data memory separated
- **Scalable Architecture**: Easy to add cache or larger memory
- **Standard Interface**: Industry-standard memory protocol

### Load/Store Architecture Benefits
1. **Flexibility**: Supports complex data structures
2. **Efficiency**: Reduced instruction memory pressure
3. **Modularity**: Memory can be upgraded independently
4. **Realism**: Matches real-world processor architectures

### Addressing Mode Advantages
1. **Base + Offset**: Supports array access patterns
2. **Immediate Addressing**: Efficient for small offsets
3. **Register Addressing**: Dynamic pointer-based access
4. **Unified Address Space**: Simple memory model

## Testing and Verification

### Memory Testing Strategy
1. **Basic Load/Store**: Simple read/write operations
2. **Address Calculation**: Various addressing modes
3. **Data Integrity**: Verify stored data matches read data
4. **Timing Verification**: Ensure proper stall behavior
5. **Memory Initialization**: Test reset functionality

### Common Test Patterns
```assembly
# Test 1: Basic store and load
loadi 0 0x10    # Base address
loadi 1 0x55    # Test data
swi 1 0 0x00    # Store test data
lwi 2 0 0x00    # Load back to different register

# Test 2: Array-like access
loadi 0 0x20    # Base address
loadi 1 0x00    # Index 0
loadi 2 0x01    # Index 1
swd 0 0 1       # Store R0 at base[0]
swd 0 0 2       # Store R0 at base[1]
```

## Performance Considerations

### Memory Access Overhead
- **Computational Instructions**: 1 clock cycle
- **Memory Instructions**: 41 clock cycles (1 + 40 wait)
- **Overall Impact**: Significant performance reduction for memory-intensive code

### Optimization Strategies
1. **Data Locality**: Group related data together
2. **Minimize Memory Access**: Use registers when possible
3. **Batch Operations**: Group multiple computations between memory accesses
4. **Algorithmic Efficiency**: Choose algorithms that minimize memory access

## Applications Enabled

### Data Structure Support
- **Arrays**: Index-based access using base + offset
- **Structures**: Field access using base + field offset
- **Buffers**: Sequential data storage and retrieval
- **Look-up Tables**: Constant data storage

### Programming Patterns
```assembly
# Array sum example
loadi 0 0x10    # Array base address
loadi 1 0x00    # Sum accumulator
loadi 2 0x00    # Loop index
loop:
    lwi 3 0 2     # Load array[index]
    add 1 1 3     # Add to sum
    add 2 2 1     # Increment index
    # ... loop condition and branch
```

## Future Enhancements

### Memory System Improvements
1. **Cache Memory**: Add L1 cache for performance
2. **Larger Memory**: Expand to 16-bit or 32-bit addressing
3. **Memory Protection**: Add access control mechanisms
4. **DMA Support**: Direct memory access for I/O

### Instruction Set Extensions
1. **Block Operations**: Multi-word load/store
2. **Atomic Operations**: Read-modify-write operations
3. **Memory Barriers**: Cache coherency support
4. **Prefetch Instructions**: Predictive memory loading

## Author
GROUP-06  
CO224 - Computer Architecture Lab  
Lab 06 - Part 1
