`include "twos_commplement.v"
`include "RegisterFile.v"
`include "PC.v"
`include "MUX_2.v"
`include "instruction_memory"
`include "contro_unit"
`include "ALU.v"

module cpu(PC,INSTRUCTION,CLK,RESET);

input [31:0]INSTRUCTION;
input CLK,RESET;
output PC;

wire [7:0]OPCODE,IMMEDIATE;
wire[2:0] READREG1,READREG2;

wire signed[7:0] OUT1,OUT2;
wire WRITEENABLE;

wire WRITEENABLE,ALUSRC,NEMUX;
wire [2:0] ALUOP;
wire signed[7:0] NEGATIVENUMBER;
wire signed[7:0] external_wire1,external_wire2;
wire signed[7:0] RESULT;


//program counter
Instruction_decode unit1(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);
control_unit unit3(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX);
reg_file  unit2(IN,OUT1,OUT2,RESULT,READREG1,READREG2,WRITEENABLE,CLK,RESET);
twos_commplement unit3(OUT2,NEGATIVENUMBER);
mux_unit unit4(OUT1,NEGATIVENUMBER,NEMUX,external_wire1);
mux_unit unit5(IMMEDIATE,external_wire1,ALUSRC,external_wire2);
alu unit6(external_wire2,REGOUT1,RESULT,ALUOP);


endmodule