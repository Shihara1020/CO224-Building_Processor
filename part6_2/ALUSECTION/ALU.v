//============================================================================
//                                    ALU (Arithmetic Logic Unit) Module
// Support for: Forward, Add, AND, OR, Multiply, Shift, Rotate operations
//============================================================================

// Include external modules
`include "ALUSECTION/multiplier.v"
`include "ALUSECTION/logicalshift.v"

//========== ALU OPERATION ENCODING ==========
/*
    SELECT SIGNAL ENCODING (3-bit):
    000 - FORWARD : Pass DATA2 (for MOV/LOADI)
    001 - ADD     : Addition of DATA1 + DATA2
    010 - AND     : Bitwise AND of DATA1 & DATA2
    011 - OR      : Bitwise OR of DATA1 | DATA2
    100 - MULT    : Multiplication of DATA1 × DATA2
    101 - SL      : Logical shift of DATA1 by DATA2 amount
    110 - SRA     : Arithmetic right shift of DATA1 by DATA2 amount
    111 - ROR     : Rotate right of DATA1 by DATA2 amount
 */

// ------------------------------------------------
//           FORWARD Operation Module
// ------------------------------------------------
// Passes DATA2 to RESULT with 1 time unit delay
module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;      
    output reg signed [7:0]RESULT;
    
       // Combinational logic with propagation delay
    always @(DATA2) begin
        #1 RESULT=DATA2;          // 1 time unit delay
    end
endmodule

// --------------------------------------------
//          ADD Operation Module
// ---------------------------------------------
// Computes DATA1 + DATA2 with 2 time units delay
module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;       
    input signed [7:0]DATA2;       
    output reg signed [7:0]RESULT;
   
    // Adder implementation
    always @(DATA1,DATA2) begin
        #2 RESULT=DATA1 + DATA2;  // 2 time unit delay
    end
endmodule

// -------------------------------------------
//          AND Operation Module
// --------------------------------------------
// Bitwise AND operation with 1 time unit delay
module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;       
    input signed [7:0]DATA2;      
    output reg signed [7:0]RESULT; 
    
    // Bitwise AND implementation 
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1 & DATA2;  // 1 time unit delay
    end
endmodule

// -------------------------------------------
//         OR Operation Module
// -------------------------------------------
// Bitwise OR operation with 1 time unit delay
module OR(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;       
    input signed [7:0]DATA2;
    output reg signed [7:0]RESULT;
    
    // Bitwise OR implementation
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1 | DATA2;  // 1 time unit delay
    end
endmodule

//---------------------------------------------------------------------------                                
//                      8:1 Multiplexer Module
// Selects one of 8 ALU operation results based on 3-bit SELECT signal
//---------------------------------------------------------------------------
module mux(I0,I1,I2,I3,I4,I5,I6,I7,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3,I4,I5,I6,I7; // 8 operation results
    input [2:0]SELECT;              
    output reg signed [7:0]RESULT;  

    // Updates result whenever any input or select signal changes
    always @(I0,I1,I2,I3,I4,I5,I6,I7,SELECT) begin
        case (SELECT) 
            3'b000: RESULT=I0;    // FORWARD output
            3'b001: RESULT=I1;    // ADD output
            3'b010: RESULT=I2;    // AND output
            3'b011: RESULT=I3;    // OR output
            3'b100: RESULT=I4;    // MULTIPLY output
            3'b101: RESULT=I5;    // LOGICAL SHIFT output
            3'b110: RESULT=I6;    // ARITHMETIC RIGHT SHIFT output
            3'b111: RESULT=I7;    // ROTATE RIGHT output
        endcase
    end 
endmodule


//----------------------------------------------------------------------------
//                                    Main ALU Module
//----------------------------------------------------------------------------
module alu(DATA1, DATA2, RESULT, SELECT, ZERO);
    input signed [7:0]DATA1;       
    input signed [7:0]DATA2;      
    input [2:0]SELECT;             
    output signed [7:0]RESULT;   
    output ZERO;                    

    // Internal wires for operation outputs
    wire signed [7:0]I0;           // FORWARD operation result
    wire signed [7:0]I1;           // ADD operation result
    wire signed [7:0]I2;           // AND operation result
    wire signed [7:0]I3;           // OR operation result
    wire signed [7:0]I4;           // MULTIPLY operation result
    wire signed [7:0]I5;           // LOGICAL SHIFT operation result
    wire signed [7:0]I6;           // ARITHMETIC RIGHT SHIFT operation result
    wire signed [7:0]I7;           // ROTATE RIGHT operation result

    //---------ALU OPERATION UNIT INSTANTIATIONS----------------
    
    FORWARD uut(DATA2,I0);                    // Forward DATA2
    ADD add_unit(DATA1,DATA2,I1);             // Signed addition
    AND and_unit(DATA1,DATA2,I2);             // Bitwise AND
    OR or_unit(DATA1,DATA2,I3);               // Bitwise OR
    multiply MUL(DATA1,DATA2,I4);           // multiplication
    Logicalshift Lshift(DATA1,DATA2,I5);    // Logical left shift
    RIGHTshift Rshift(DATA1,DATA2,I6,2'b11);    // Arithmetic right shift
    RIGHTshift RORshift(DATA1,DATA2,I7,2'b00);  // Rotate right
    
    // Selects final result based on operation selector
    mux mux_unit(I0,I1,I2,I3,I4,I5,I6,I7,SELECT,RESULT);
    
    // Zero flag is set when the ALU result equals zero
    // Used by control unit for conditional branch instructions (BEQ/BNE)
    assign ZERO=(RESULT==0)?1'b1:1'b0;

endmodule