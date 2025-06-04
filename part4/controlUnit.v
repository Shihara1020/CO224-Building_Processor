module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX,BRANCH,JUMP);
    input [7:0] OPCODE;          // 8-bit instruction opcode from instruction memory
    
    // Output control signals
    output reg [2:0] ALUOP;      // ALU operation selection (3-bit for 8 operations)
    output reg ALUSRC;           // ALU source selection (0=register, 1=immediate)
    output reg WRITEENABLE;      // Register write enable (1=write, 0=no write)
    output reg NEMUX;            // Negative/2's complement selection for subtraction
    output reg BRANCH;           // Branch control signal for conditional jumps
    output reg JUMP;             // Unconditional jump control signal


    // ============================================
    //           OPCODE DEFINITIONS
    // ============================================
                    // OP_ADD   = 8'b00000000;  
                    // OP_SUB   = 8'b00000001;  
                    // OP_AND   = 8'b00000010;  
                    // OP_OR    = 8'b00000011;  
                    // OP_MOV   = 8'b00000100;  
                    // OP_LOADI = 8'b00000101;
                    // OP_j     = "00000110";    // Unconditional jump: PC = target_address
                    // OP_beq   = "00000111";    // Branch if equal: if(RS1==RS2) PC = target_address
    

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
        //Add 1 delay
        #1 
        
        if (OPCODE==8'b00000000) begin       // ADD 
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b001;                    // ALU performs addition
            ALUSRC=1'b1;                     // Use register data 
            NEMUX=1'b0;                      // No negation needed 
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000001) begin  // SUB 
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b001;                    // ALU performs addition 
            ALUSRC=1'b1;                     // Use register data
            NEMUX=1'b1;                      // Enable negation for subtraction 
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000010) begin  // AND 
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b010;                    // ALU performs bitwise AND
            ALUSRC=1'b1;                     // Use register data 
            NEMUX=1'b0;                      // No negation needed 
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000011) begin  // OR 
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b011;                    // ALU performs bitwise OR
            ALUSRC=1'b1;                     // Use register data 
            NEMUX=1'b0;                      // No negation needed 
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000100) begin  // Mov 
            WRITEENABLE=1'b1;                // Enable resiter write
            ALUOP=3'b000;                    // ALU performs forward operation 
            ALUSRC=1'b1;                     // Use register data 
            NEMUX=1'b0;                      // No negation needed
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000101) begin  // LOADI
            WRITEENABLE=1'b1;                // Enable register write
            ALUOP=3'b000;                    // ALU performs forward operation
            ALUSRC=1'b0;                     // Use immediate data
            NEMUX=1'b0;                      // No negation needed 
            BRANCH=1'b0;                     // Not a branch instruction
            JUMP=1'b0;                       // Not a jump instruction
        end
        else if (OPCODE==8'b00000110) begin  // JUMP 
            WRITEENABLE=1'b0;                // No register write 
            ALUOP=3'b000;                    // ALU operation 
            ALUSRC=1'b0;                     // ALU source not used 
            NEMUX=1'b0;                      // Negation not used 
            BRANCH=1'b0;                     // Not a conditional branch
            JUMP=1'b1;                       // Enable unconditional jump
        end--
        else if (OPCODE==8'b00000111) begin  // BEQ (Branch if Equal) o
            WRITEENABLE=1'b0;                // No register write 
            ALUOP=3'b001;                    // ALU performs subtraction for comparison
            ALUSRC=1'b1;                     // Use register data 
            NEMUX=1'b1;                      // Enable negation for subtraction comparison
            BRANCH=1'b1;                     // Enable conditional branching
            JUMP=1'b0;                       // Not an unconditional jump
        end
    end
endmodule