`include "twos_commplement.v"
`include "RegisterFile.v"
`include "PC.v"
`include "MUX_2.v"
`include "instruction_memory.v"
`include "controlUnit.v"
`include "ALU.v"

module cpu(PC,INSTRUCTION,CLK,RESET);

// ==== Inputs and Outputs ====
input [31:0] INSTRUCTION;
input CLK, RESET;
output [31:0] PC; 


// ==== Internal Wires ====
// Instruction decoding
wire [7:0] OPCODE, IMMEDIATE;
wire [2:0] READREG1, READREG2, WRITEREG;


// Control Unit
wire WRITEENABLE, ALUSRC, NEMUX;
wire [2:0] ALUOP;


// Register File
wire signed [7:0] REGOUT1, REGOUT2, WRITEDATA;


// Two's Complement
wire signed [7:0] NEGATIVENUMBER;

// Mux outputs
wire signed [7:0] mux1_out, mux2_out;





// ==== Module Connections ====


// start to pc counter -> decode the instruction -> Control unit -> Register File->2's complemet->Mux1 ->mux2->ALU

// 1. Program Counter-done
pc_unit PCUNIT(RESET,CLK,PC);

// 2. Instruction Decode - done
Instruction_decode DECODER(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);

// 3. Control Unit - done
control_unit control(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX);

// 4. Register File 
reg_file  REGFILE(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET);

// 5. Two's Complement
twos_commplement twos(REGOUT2,NEGATIVENUMBER);


// 6. First Mux: Select between REGOUT2 and NEGATIVENUMBER
mux_unit MUX1(REGOUT2,NEGATIVENUMBER,NEMUX,mux1_out);

// 7. Second Mux: Select between mux1_out and IMMEDIATE
mux_unit MUX2(IMMEDIATE,mux1_out,ALUSRC,mux2_out);

// 8. ALU
alu ALU(REGOUT1,mux2_out,WRITEDATA,ALUOP);


endmodule