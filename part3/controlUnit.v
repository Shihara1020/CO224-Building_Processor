//==============================================================================
//                      Control Unit Module for Simple Processor
// Description: Generates control signals based on instruction opcode
//==============================================================================
module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX);
    input [7:0] OPCODE;          // 8-bit instruction opcode
    output reg [2:0] ALUOP;      // Register file write enable
    output reg ALUSRC;           // ALU source selection (0: reg, 1: immediate)
    output reg WRITEENABLE;      // ALU operation select
    output reg NEMUX;            // Negate mux control for subtraction

    //========================================================================
    //                       OPCODE DEFINITIONS
    //========================================================================
                            // OP_ADD   = 8'b00000000;  
                            // OP_SUB   = 8'b00000001;  
                            // OP_AND   = 8'b00000010;  
                            // OP_OR    = 8'b00000011;  
                            // OP_MOV   = 8'b00000100;  
                            // OP_LOADI = 8'b00000101;


    //========================================================
    //                ALU OPERATION CODES
    //========================================================
    // ALU operation encoding:
    //             3'b000 - Forward (for MOV, LOADI)
    //             3'b001 - Add/Subtract
    //             3'b010 - AND
    //             3'b011 - OR


    //========================================================================
    //               CONTROL SIGNAL MEANINGS
    //=========================================================================
    // WRITEENABLE: 1 = Enable writing to register file, 0 = Disable
    // ALUSRC:      1 = Use register data, 0 = Use immediate data
    // NEMUX:       1 = Negate second operand (for subtraction), 0 = No negation
    // ALUOP:       3-bit code to select ALU operation

    //===================================================
    //                MAIN CONTROL LOGIC
    //===================================================

    always @(OPCODE) begin
        // Add 1 delay 
        #1
        if (OPCODE==8'b00000000) begin       // Add
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b001;                    // ALU performs addition
            ALUSRC=1'b1;                     // Use register data
            NEMUX=1'b0;                      // No negation needed
        end
        else if (OPCODE==8'b00000001) begin  // Sub 
            WRITEENABLE = 1'b1;              // Enable register write
            ALUOP       = 3'b001;            // ALU performs addition (with negation)
            ALUSRC      = 1'b1;              // Use register data
            NEMUX       = 1'b1;              // Negate second operand for subtraction
            
        end
        else if (OPCODE==8'b00000010) begin  // And 
            WRITEENABLE = 1'b1;              // Enable register write
            ALUOP       = 3'b010;            // ALU performs bitwise AND
            ALUSRC      = 1'b1;              // Use register data
            NEMUX       = 1'b0;              // No negation needed
            
        end
        else if (OPCODE==8'b00000011) begin // Or
            WRITEENABLE = 1'b1;             // Enable register write
            ALUOP       = 3'b011;           // ALU performs bitwise OR
            ALUSRC      = 1'b1;             // Use register data
            NEMUX       = 1'b0;             // No negation needed
            
        end
        else if (OPCODE==8'b00000100) begin // Mov
            WRITEENABLE = 1'b1;             // Enable register write
            ALUOP       = 3'b000;           // ALU passes data through
            ALUSRC      = 1'b1;             // Use register data
            NEMUX       = 1'b0;             // No negation needed
            
        end
        else if (OPCODE==8'b00000101) begin  // Loadi
            WRITEENABLE = 1'b1;              // Enable register write
            ALUOP       = 3'b000;            // ALU passes data through
            ALUSRC      = 1'b0;              // Use immediate data (not register)
            NEMUX       = 1'b0;              // No negation needed
            
        end    
    end
endmodule