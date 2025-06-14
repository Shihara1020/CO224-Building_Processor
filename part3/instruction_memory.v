//==============================================================================
//                       INSTRUCTION FORMAT SPECIFICATION
//==============================================================================
/*

Field Descriptions:
- OPCODE:    8-bit operation code (bits 31-24)
- WRITEREG:  3-bit destination register address (bits 20-18)
- READREG1:  3-bit first source register address (bits 10-8)
- READREG2:  3-bit second source register address (bits 2-0)
- IMMEDIATE: 8-bit immediate value for LOADI (bits 7-0)
*/

//==============================================================================
//                         INSTRUCTION DECODE MODULE
//==============================================================================
module Instruction_decode(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);
    input  [31:0]INSTRUCTION;
    output reg [7:0]OPCODE;
    output reg [2:0] READREG1,READREG2,WRITEREG;
    output reg [7:0]IMMEDIATE;
    
    always @(INSTRUCTION) begin
            OPCODE=INSTRUCTION[31:24];      // Bits 31-24: Operation code
            READREG1=INSTRUCTION[10:8];     // Bits 10-8:  First source reg
            READREG2=INSTRUCTION[2:0];      // Bits 2-0:   Second source register    
            WRITEREG=INSTRUCTION[18:16];    // Bits 20-18: Destination register
            IMMEDIATE=INSTRUCTION[7:0];     // Bits 7-0:   Immediate value
    end
endmodule






//==============================================================================
// TESTBENCH FOR INSTRUCTION DECODE
// Verifies correct decoding of various instruction formats
//==============================================================================

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


