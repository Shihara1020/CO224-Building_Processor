module Instruction_decode(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG,OFFSET);
    input  [31:0]INSTRUCTION;
    output reg [7:0]OPCODE;
    output reg [2:0] READREG1,READREG2,WRITEREG;
    output reg [7:0]IMMEDIATE;
    output reg [7:0] OFFSET;
    
    always @(INSTRUCTION) begin
            OPCODE=INSTRUCTION[31:24];
            READREG1=INSTRUCTION[10:8];
            READREG2=INSTRUCTION[2:0];
            WRITEREG=INSTRUCTION[18:16];
            IMMEDIATE=INSTRUCTION[7:0];
            OFFSET=INSTRUCTION[23:16];
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

