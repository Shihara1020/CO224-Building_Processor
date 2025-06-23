//============================================================================
//                                    CPU Top-Level Module
// Complete CPU implementation with instruction fetch, decode, execute pipeline
//============================================================================

// Include all required module files
`include "twos_commplement.v"
`include "RegisterFile.v"
`include "PC.v"
`include "MUX_2.v"
`include "instruction_memory.v"
`include "controlUnit.v"
`include "ALUSECTION/ALU.v"
`include "DataMemory.v"

module cpu(PC,INSTRUCTION,CLK,RESET);

    input [31:0] INSTRUCTION;       // 32-bit instruction word from instruction memory
    input CLK;                      // clock 
    input RESET;                    // reset 
    output [31:0] PC;               // 32-bit Program Counter output (current instruction address)

    //INTERNAL WIRE DECLARATIONS
    
    //Instruction Decode Signals 
    wire [7:0] OPCODE;              // 8-bit operation code from instruction[31:24]
    wire [7:0] IMMEDIATE;           // 8-bit immediate value from instruction[7:0]
    wire [7:0] OFFSET;              // 8-bit branch offset from instruction[23:16]
    wire [2:0] READREG1;            // 3-bit address for first source register
    wire [2:0] READREG2;            // 3-bit address for second source register
    wire [2:0] WRITEREG;            // 3-bit address for destination register

    // Control Unit Signals
    wire WRITEENABLE;               // Register file write enable signal
    wire ALUSRC;                    // ALU source selector (0: register, 1: immediate)
    wire NEMUX;                     // Negative number MUX selector (0: positive, 1: two's complement)
    wire [1:0] BRANCH;              // 2-bit branch control signals
    wire [2:0] ALUOP;               // 3-bit ALU operation selector
    wire READ;                      // Data memory read enable
    wire WRITE;                     // Data memory write enable
    wire BUSYWAIT;                  // Memory busy wait signal
    wire WRITESRC;                  // Write source selector (0: ALU result, 1: memory data)

    // Register File Signals
    wire signed [7:0] REGOUT1;      // 8-bit signed output from first read port
    wire signed [7:0] REGOUT2;      // 8-bit signed output from second read port
    wire signed [7:0] ALUOUTPUT;    // 8-bit signed data to write back to register file
    wire signed [7:0] REGWRITEDATA; 

    // ALU Signals
    wire ZERO;                      // Zero flag output from ALU (used for branching)

    // Two's Complement Signals
    wire signed [7:0] NEGATIVENUMBER; // Two's complement of REGOUT2

    // Multiplexer Output Signals
    wire signed [7:0] mux1_out;     //Output from first MUX (selects between REGOUT2 and its negative)
    wire signed [7:0] mux2_out;     //Output from second MUX (selects between register and immediate)

    // Memory Signals
    wire signed [7:0]MEMREADDATA;   // Data read from memory


    
    // 1. Program Counter Unit 
    // Updates PC on each clock cycle based on branch conditions
    pc_unit PCUNIT(RESET, CLK, PC, BRANCH, ZERO, OFFSET,BUSYWAIT);

    // 2. Instruction Decoder
    // Extracts all instruction fields from 32-bit instruction word
    // Provides addresses, immediate values, and offset for other units
    Instruction_decode DECODER(INSTRUCTION, OPCODE, IMMEDIATE, READREG1, READREG2, WRITEREG, OFFSET);

    // 3. Control Unit
    // Generates all control signals based on instruction opcode
    // Determines ALU operation, data path routing, and write enables
    control_unit control(OPCODE, WRITEENABLE, ALUSRC, ALUOP, NEMUX, BRANCH,READ,WRITE,BUSYWAIT,WRITESRC);

    // 4. Register File
    // 8-register storage with dual read ports and single write port
    // Provides source operands and stores computation results
    reg_file REGFILE(REGWRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);

    // 5. Two's Complement Unit
    // Converts REGOUT2 to its two's complement (negative value)
    // Used for subtraction operations (A - B = A + (-B))
    twos_commplement twos(REGOUT2, NEGATIVENUMBER);

    // 6. First Multiplexer (Sign Selection)
    // Selects between original REGOUT2 and its two's complement
    // NEMUX = 0: use REGOUT2 (for addition/other operations)
    // NEMUX = 1: use NEGATIVENUMBER (for subtraction operations)
    mux_unit MUX1(REGOUT2, NEGATIVENUMBER, NEMUX, mux1_out);

    // 7. Second Multiplexer (Operand Source Selection)
    // Selects between register operand and immediate value for ALU input
    // ALUSRC = 0: use IMMEDIATE value (immediate operations)
    // ALUSRC = 1: use mux1_out (register-register operations)
    mux_unit MUX2(IMMEDIATE, mux1_out, ALUSRC, mux2_out);

    // 8. Arithmetic Logic Unit (ALU)
    // Performs arithmetic and logic operations on two 8-bit signed operands
    // First operand: REGOUT1 (always from register)
    // Second operand: mux2_out (from register or immediate via MUXes)
    // Generates result (ALUOPTPUT) and zero flag for branching
    alu ALU(REGOUT1, mux2_out, ALUOUTPUT, ALUOP, ZERO);
    


    data_memory data_memory_unit(CLK,RESET,READ,WRITE,ALUOUTPUT,REGOUT1,MEMREADDATA,BUSYWAIT);
    //select
    //0-aluresult
    //1-memorydata
    mux_unit writedataSelector(ALUOUTPUT,MEMREADDATA,WRITESRC,REGWRITEDATA);

endmodule