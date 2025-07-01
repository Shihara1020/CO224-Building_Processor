//============================================================================
//                                   Control Unit Module
// Generates all control signals for CPU datapath based on instruction opcode
//============================================================================
`timescale  1ns/100ps

module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX,BRANCH,READ,WRITE,BUSYWAIT,WRITESRC,HOLD,INS_BUSYWAIT);
    input [7:0]OPCODE;
    input BUSYWAIT;                //signal the control unit if there's reading or writing happening to the memory unit   
    input INS_BUSYWAIT;            // Data memory busy signal       

    //========== OUTPUT PORT DECLARATIONS ==========
    output reg [2:0]ALUOP;         // 3-bit ALU operation selector
    output reg ALUSRC;             // ALU source selector (0: immediate, 1: register)
    output reg WRITEENABLE;        // Register file write enable (1: write, 0: no write)
    output reg NEMUX;              // Negative number MUX selector (0: positive, 1: two's complement)
    output reg [1:0]BRANCH;        // 2-bit branch control signals
    output reg WRITE;              // Memory write enable 
    output reg WRITESRC;           // Selector between ALU result and Memory read(0: ALU result ,1:Memory read data  ) 
    output reg READ;               // Memory read enable
    output reg HOLD;               // Control signal for pc to determine whether to stall or not  

    //========== INSTRUCTION SET ARCHITECTURE ==========
    /*
     * OPCODE DEFINITIONS:
     * 00000000 (0x00) - ADD    : Add two registers
     * 00000001 (0x01) - SUB    : Subtract two registers  
     * 00000010 (0x02) - AND    : Bitwise AND of two registers
     * 00000011 (0x03) - OR     : Bitwise OR of two registers
     * 00000100 (0x04) - MOV    : Move register to register
     * 00000101 (0x05) - LOADI  : Load immediate value to register
     * 00000110 (0x06) - J      : Unconditional jump
     * 00000111 (0x07) - BEQ    : Branch if equal (zero flag set)
     * 00001000 (0x08) - BNE    : Branch if not equal (zero flag clear)
     * 00001001 (0x09) - MULT   : Multiply two registers
     * 00001010 (0x0A) - SL     : Shift left logical
     * 00001100 (0x0C) - SRA    : Shift right arithmetic
     * 00001101 (0x0D) - ROR    : Rotate right
     * 00001110 (0x0E) - LWD    : Load word direct (register + register)
     * 00001111 (0x0F) - LWI    : Load word immediate (register + immediate)
     * 00010000 (0x10) - SWD    : Store word direct (register + register)
     * 00010001 (0x11) - SWI    : Store word immediate (register + immediate)
     */

    //========== CONTROL SIGNAL ENCODING ==========
    /*
     * ALUOP Encoding:
     * 000 - Forward (pass-through for MOV/LOADI)
     * 001 - Add/Subtract operation
     * 010 - Bitwise AND
     * 011 - Bitwise OR
     * 100 - Multiplication
     * 101 - Shift left logical
     * 110 - Shift right arithmetic
     * 111 - Rotate right
     *
     * BRANCH Encoding:
     * 00 - Normal sequential execution
     * 01 - Unconditional jump
     * 10 - Branch if equal (BEQ)
     * 11 - Branch if not equal (BNE)
     */

    
    // Generate HOLD signal to stall CPU when memory operations are in progress
    // This prevents the CPU from fetching new instructions or updating registers

    always @(*) begin
        // Stall CPU if either data memory or instruction memory is busy
        HOLD=BUSYWAIT || INS_BUSYWAIT;                     
    end

    //========== COMBINATIONAL CONTROL LOGIC ==========
    // Control signals are generated combinationally based on opcode
    // 1 time unit delay 
    always @(OPCODE) begin
        #1
        if (OPCODE == 8'b00000000) begin        // ADD instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b001;         // ALU performs addition
            ALUSRC=1'b1;          // Use register as second operand
            NEMUX=1'b0;           // Use positive value (no two's complement)
            BRANCH = 2'b00;       // Sequential execution (no branch)

            // control signals to control memory operations 
            READ=1'b0;             
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00000001) begin   // SUB instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b001;         // ALU performs addition (with negative second operand)
            ALUSRC=1'b1;          // Use register as second operand
            NEMUX=1'b1;           // Use two's complement for subtraction (A - B = A + (-B))
            BRANCH=2'b00;         // Sequential execution (no branch)

            // control signals to control memory operations 
            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00001001) begin   // MULT instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b100;         // ALU performs multiplication
            ALUSRC=1'b1;          // Use register as second operand
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)

            // control signals to control memory operations 
            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end

        
        else if (OPCODE==8'b00000010) begin   // AND instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b010;         // ALU performs bitwise AND
            ALUSRC=1'b1;          // Use register as second operand
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            // control signals to control memory operations 
            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00000011) begin   // OR instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b011;         // ALU performs bitwise OR
            ALUSRC=1'b1;          // Use register as second operand
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)

            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00000100) begin   // MOV instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b000;         // ALU forwards input (pass-through)
            ALUSRC=1'b1;          // Use register as source
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)

            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00000101) begin   // LOADI instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b000;         // ALU forwards input (pass-through)
            ALUSRC=1'b0;          // Use immediate value as source
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations
            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end

        
        else if (OPCODE==8'b00000110) begin   // J (Jump) instruction
            WRITEENABLE=1'b0;     // No register write needed
            ALUOP=3'b000;         // ALU operation not used
            ALUSRC=1'b0;          // Source selection not used
            NEMUX=1'b0;           // Sign selection not used
            BRANCH=2'b01;         // Unconditional jump


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00000111) begin   // BEQ (Branch if Equal) instruction
            WRITEENABLE= 1'b0;     // No register write needed
            ALUOP=3'b001;         // ALU performs subtraction to set zero flag
            ALUSRC=1'b1;          // Use register for comparison
            NEMUX=1'b1;           // Use two's complement for comparison (A - B)
            BRANCH=2'b10;         // Branch if zero flag is set


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00001000) begin   // BNE (Branch if Not Equal) instruction
            WRITEENABLE=1'b0;     // No register write needed
            ALUOP=3'b001;         // ALU performs subtraction to set zero flag
            ALUSRC=1'b1;          // Use register for comparison
            NEMUX=1'b1;           // Use two's complement for comparison (A - B)
            BRANCH=2'b11;         // Branch if zero flag is clear


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end

        
        else if (OPCODE==8'b00001010) begin   // SL (Shift Left) instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b101;         // ALU performs left shift
            ALUSRC=1'b0;          // Use immediate value as shift amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00001100) begin   // SRA (Shift Right Arithmetic) instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b110;         // ALU performs arithmetic right shift
            ALUSRC=1'b0;          // Use immediate value as shift amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)

            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        
        else if (OPCODE==8'b00001101) begin   // ROR (Rotate Right) instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b111;         // ALU performs rotate right
            ALUSRC=1'b0;          // Use immediate value as rotate amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b0;
            WRITESRC=1'b0;
        end
        else if (OPCODE==8'b00001110) begin   // lwd instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b000;         // ALU perform FORWARD
            ALUSRC=1'b1;          // Use immediate value as rotate amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations

            READ=1'b1;            // Enable memory read
            WRITE=1'b0;      
            WRITESRC=1'b1;        // Write memory data to register
        end
        else if (OPCODE==8'b00001111) begin   // lwi instruction
            WRITEENABLE=1'b1;     // Enable write to destination register
            ALUOP=3'b000;         // ALU performs FORWARD
            ALUSRC=1'b0;          // Use immediate value as rotate amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations

            READ=1'b1;            // Enable memory read
            WRITE=1'b0;
            WRITESRC=1'b1;        // Write memory data to register
        end
        else if (OPCODE==8'b00010000) begin   // swd instruction
            WRITEENABLE=1'b0;     // Enable write to destination register
            ALUOP=3'b000;         // ALU performs FOWARD
            ALUSRC=1'b1;          // Use immediate value as rotate amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations

            READ=1'b0;
            WRITE=1'b1;            // Enable memory write
            WRITESRC=1'b0;         //not used
        end
        else if (OPCODE==8'b00010001) begin   //swi instruction
            WRITEENABLE=1'b0;     // Enable write to destination register
            ALUOP=3'b000;         // ALU performs FOWARD
            ALUSRC=1'b0;          // Use immediate value as rotate amount
            NEMUX=1'b0;           // Use positive value
            BRANCH=2'b00;         // Sequential execution (no branch)


            //control signals to control memory operations
            
            READ=1'b0;
            WRITE=1'b1;           // Enable memory write      
            WRITESRC=1'b0;        // not used
        end

    end

endmodule