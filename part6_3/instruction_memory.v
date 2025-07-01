//============================================================================
//                               Instruction Decode Module
// Decodes 32-bit instruction word into constituent fields for CPU execution
// Supports multiple instruction formats by extracting different bit fields
// 
// Instruction Format (32-bit):
// [31:24] - OPCODE     (8 bits)  - Operation code
// [23:16] - OFFSET     (8 bits)  - Branch/Jump offset  
// [18:16] - WRITEREG   (3 bits)  - Destination register address
// [10:8]  - READREG1   (3 bits)  - First source register address  
// [7:0]   - IMMEDIATE  (8 bits)  - Immediate value/constant
// [2:0]   - READREG2   (3 bits)  - Second source register address
//============================================================================
`timescale  1ns/100ps
module Instruction_decode(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG,OFFSET);

    //========== INPUT PORT DECLARATIONS ==========
    input [31:0] INSTRUCTION;       // 32-bit instruction word from instruction memory

    //========== OUTPUT PORT DECLARATIONS ==========
    output reg [7:0] OPCODE;        // 8-bit operation code (determines instruction type)
    output reg [2:0] READREG1;      // 3-bit address for first source register (R0-R7)
    output reg [2:0] READREG2;      // 3-bit address for second source register (R0-R7)
    output reg [2:0] WRITEREG;      // 3-bit address for destination register (R0-R7)
    output reg [7:0] IMMEDIATE;     // 8-bit immediate value for immediate operations
    output reg [7:0] OFFSET;        // 8-bit offset for branch/jump instructions

    //========== COMBINATIONAL DECODE LOGIC ==========
    // Decode logic triggers whenever instruction changes
    // All field extractions happen simultaneously (combinational)
    always @(INSTRUCTION) begin
        // Extract operation code from most significant bits
        // Determines the type of operation to be performed
        OPCODE = INSTRUCTION[31:24];
        
        // Extract first source register address
        // Used for operations requiring first operand from register file
        READREG1 = INSTRUCTION[10:8];
        
        // Extract second source register address  
        // Used for operations requiring second operand from register file
        READREG2 = INSTRUCTION[2:0];
        
        // Extract destination register address
        // Specifies where result should be written in register file
        WRITEREG = INSTRUCTION[18:16];
        
        // Extract immediate value from least significant bits
        // Used for immediate operations (constants embedded in instruction)
        IMMEDIATE = INSTRUCTION[7:0];
        
        // Extract offset value for branch/jump instructions
        // Used to calculate branch target addresses
        OFFSET = INSTRUCTION[23:16];
    end

endmodule

//============================================================================
//                           Instruction Decode Testbench
// Testbench for verifying instruction decode functionality
// Tests extraction of all instruction fields from sample instruction word
//============================================================================

// module testbench;
    // reg [31:0] INSTRUCTION;
    // wire [7:0] OPCODE,IMMEDIATE;
    // wire [2:0] READREG1,READREG2,WRITEREG;

    // Instruction_decode uut(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);

    // initial begin
    //     $monitor("Time=%0t | INSTRUCTION=%b | OPCODE=%b | READREG1=%b | READREG2=%b | WRITEREG=%b | IMMEDIATE=%b",$time, INSTRUCTION, OPCODE, READREG1, READREG2, WRITEREG, IMMEDIATE);

    //     // Test 1
    //     INSTRUCTION = 32'b1001111_000011000_10101010_11110000;
        

    //     $finish;
    // end
// endmodule

