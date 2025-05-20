module Instruction_decode(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);
    input  [31:0]INSTRUCTION;
    output [7:0]OPCODE;
    output [2:0] READREG1,READREG2,WRITEREG;
    output [7:0]IMMEDIATE;
    
    always @(INSTRUCTION) begin
            OPCODE=INSTRUCTION[31:24];
            READREG1=INSTRUCTION[18:16];
            READREG2=INSTRUCTION[2:0];
            WRITEREG=INSTRUCTION[10:8];
            IMMEDIATE=INSTRUCTION[7:0];

    end


endmodule


