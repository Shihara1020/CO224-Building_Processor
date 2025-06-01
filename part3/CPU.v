//==================================================================================
//                             Simple CPU Implementation
// Description: Single-cycle processor with basic arithmetic and logic operations
// Data Width: 8-bit data, 32-bit instructions, 32-bit PC
// Author: Dewagedara D.M.E.S. / PERERA W.S.S.
//=================================================================================


//===================================================================
//                      REQUIRED MODULE INCLUDES
//===================================================================
`include "twos_commplement.v"       // Two's complement conversion module
`include "RegisterFile.v"           // Register file implementation
`include "PC.v"                     // Program counter module
`include "MUX_2.v"                  // 2-to-1 multiplexer module
`include "instruction_memory.v"     // Instruction memory module
`include "controlUnit.v"            // Control unit module
`include "ALU.v"                    // Arithmetic Logic Unit module


//=============================================================
//                         MAIN CPU MODULE
//=============================================================
module cpu(PC,INSTRUCTION,CLK,RESET);

    // ==== Inputs and Outputs ====
    input [31:0] INSTRUCTION;       // 32-bit instruction from instruction memory
    input CLK, RESET;               // clock signal, reset signal
    output [31:0] PC;               // 32-bit program counter output




    //--------------------------------------------------------------------------
    //              INSTRUCTION DECODE SIGNALS
    //--------------------------------------------------------------------------
    // Instruction format: [OPCODE][RD][RT][RS][IMMEDIATE]
    wire [7:0]  OPCODE;         // 8-bit operation code
    wire [7:0]  IMMEDIATE;      // 8-bit immediate value for LOADI
    wire [2:0]  READREG1;       // 3-bit address for first source register (RS)
    wire [2:0]  READREG2;       // 3-bit address for second source register (RT)  
    wire [2:0]  WRITEREG;       // 3-bit address for destination register (RD)



    //--------------------------------------------------------------------------
    //               CONTROL UNIT SIGNALS
    //--------------------------------------------------------------------------
    wire        WRITEENABLE;    // Register file write enable (1=write, 0=read-only)
    wire        ALUSRC;         // ALU source select (1=register, 0=immediate)
    wire        NEMUX;          // Negate mux control (1=negate for SUB, 0=normal)
    wire [2:0]  ALUOP;          // 3-bit ALU operation select


    //--------------------------------------------------------------------------
    //               REGISTER FILE SIGNALS  
    //--------------------------------------------------------------------------
    wire signed [7:0] REGOUT1;  // Data output from first source register
    wire signed [7:0] REGOUT2;  // Data output from second source register
    wire signed [7:0] WRITEDATA;// Data to be written back to destination register


    //--------------------------------------------------------------------------
    //               ARITHMETIC PROCESSING SIGNALS
    //--------------------------------------------------------------------------
    wire signed [7:0] NEGATIVENUMBER;  // Two's complement of REGOUT2 (for subtraction)


    //--------------------------------------------------------------------------
    //               MULTIPLEXER OUTPUT SIGNALS
    //--------------------------------------------------------------------------
    wire signed [7:0] mux1_out; // Output of first mux (REGOUT2 vs NEGATIVENUMBER)
    wire signed [7:0] mux2_out; // Output of second mux (register vs immediate)

    //==========================================================================
    //               CPU DATAPATH IMPLEMENTATION
    //==========================================================================


    /*
    DATAPATH FLOW:
                1. PC generates instruction address
                2. Instruction is decoded into component fields
                3. Control unit generates control signals from opcode
                4. Register file provides source operands
                5. Two's complement unit prepares for subtraction if needed
                6. MUX1 selects between normal/negated second operand
                7. MUX2 selects between register data and immediate value
                8. ALU performs the specified operation
                9. Result is written back to destination register
    */


    //--------------------------------------------------------------------------
    //                        STAGE 1: PROGRAM COUNTER
    // Generates sequential instruction addresses
    // Increments by 4 each clock cycle (word-aligned addressing)
    //--------------------------------------------------------------------------
    pc_unit PCUNIT(RESET,CLK,PC);


    //--------------------------------------------------------------------------
    //                        STAGE 2: INSTRUCTION DECODE
    // Breaks down 32-bit instruction into component fields
    // Format: [31:24]OPCODE [23:21]RD [20:18]RT [17:15]RS [14:7]UNUSED [6:0]IMM
    //--------------------------------------------------------------------------
    Instruction_decode DECODER(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG);


    //--------------------------------------------------------------------------
    //                        STAGE 3: CONTROL UNIT
    // Generates control signals based on instruction opcode
    // Controls: Register writes, ALU operation, data source selection
    //--------------------------------------------------------------------------
    control_unit control(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX);


    //--------------------------------------------------------------------------
    //                        STAGE 4: REGISTER FILE
    // 8-register file with dual read ports and single write port
    // Capacity: 8 registers × 8 bits each (R0-R7)
    // Simultaneous read of two registers, write on clock edge
    //--------------------------------------------------------------------------
    reg_file  REGFILE(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET);


    //--------------------------------------------------------------------------
    //                       STAGE 5: TWO'S COMPLEMENT UNIT
    // Converts positive number to negative for subtraction
    // Operation: NEGATIVENUMBER = -REGOUT2 (two's complement)
    // Enables subtraction using ALU's adder (A - B = A + (-B))
    //--------------------------------------------------------------------------
    twos_commplement twos(REGOUT2,NEGATIVENUMBER);


    //--------------------------------------------------------------------------
    //                       STAGE 6: FIRST MULTIPLEXER (Negation Control)
    // Selects between normal and negated second operand
    // Control: NEMUX (0=normal REGOUT2, 1=negated for subtraction)
    //--------------------------------------------------------------------------
    mux_unit MUX1(REGOUT2,NEGATIVENUMBER,NEMUX,mux1_out);


    //--------------------------------------------------------------------------
    //                      STAGE 7: SECOND MULTIPLEXER (Source Selection)
    // Selects between register data and immediate value
    // Control: ALUSRC (0=immediate, 1=register data)
    //--------------------------------------------------------------------------
    mux_unit MUX2(IMMEDIATE,mux1_out,ALUSRC,mux2_out);

    //--------------------------------------------------------------------------
    //                     STAGE 8: ARITHMETIC LOGIC UNIT (ALU)
    // Performs arithmetic and logic operations
    // Operations: ADD, SUB , AND, OR, MOV, LOADI
    //--------------------------------------------------------------------------
    alu ALU(REGOUT1,mux2_out,WRITEDATA,ALUOP);


endmodule