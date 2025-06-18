//============================================================================
//                               Instruction Decode Module
// Decodes 32-bit instruction word into constituent fields for CPU execution
// 
// Instruction Format (32-bit):
// [31:24] - OPCODE     (8 bits)  - Operation code
// [23:16] - OFFSET     (8 bits)  - Branch/Jump offset  
// [18:16] - WRITEREG   (3 bits)  - Destination register address
// [10:8]  - READREG1   (3 bits)  - First source register address  
// [7:0]   - IMMEDIATE  (8 bits)  - Immediate value/constant
// [2:0]   - READREG2   (3 bits)  - Second source register address
//============================================================================

module Instruction_decode(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG,OFFSET);
    input [31:0] INSTRUCTION;       // 32-bit instruction word from instruction memory
    output reg [7:0] OPCODE;        // 8-bit operation code
    output reg [2:0] READREG1;      // 3-bit address for first source register 
    output reg [2:0] READREG2;      // 3-bit address for second source register 
    output reg [2:0] WRITEREG;      // 3-bit address for destination register 
    output reg [7:0] IMMEDIATE;     // 8-bit immediate value for immediate operations
    output reg [7:0] OFFSET;        // 8-bit offset for branch/jump instructions

    // Decode logic triggers whenever instruction changes
    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[31:24];
        READREG1 = INSTRUCTION[10:8];
        READREG2 = INSTRUCTION[2:0];
        WRITEREG = INSTRUCTION[18:16];
        IMMEDIATE = INSTRUCTION[7:0];
        OFFSET = INSTRUCTION[23:16];
    end

endmodule


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


