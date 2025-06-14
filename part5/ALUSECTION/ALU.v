//============================================================================
//                                    ALU (Arithmetic Logic Unit) Module
// Complete ALU implementation supporting 8 different operations
// Features:
// - 8-bit signed arithmetic and logic operations
// - Configurable operation selection via 3-bit SELECT signal
// - Zero flag generation for conditional branching
// - Modular design with separate operation units
// - Support for: Forward, Add, AND, OR, Multiply, Shift, Rotate operations
//============================================================================

// Include external operation modules
`include "ALUSECTION/multiplier.v"
`include "ALUSECTION/logicalshift.v"

//========== ALU OPERATION ENCODING ==========
/*
 * SELECT SIGNAL ENCODING (3-bit):
 * 000 - FORWARD : Pass DATA2 through unchanged (for MOV/LOADI)
 * 001 - ADD     : Addition of DATA1 + DATA2
 * 010 - AND     : Bitwise AND of DATA1 & DATA2
 * 011 - OR      : Bitwise OR of DATA1 | DATA2
 * 100 - MULT    : Multiplication of DATA1 × DATA2
 * 101 - SL      : Logical left shift of DATA1 by DATA2 amount
 * 110 - SRA     : Arithmetic right shift of DATA1 by DATA2 amount
 * 111 - ROR     : Rotate right of DATA1 by DATA2 amount
 */

//============================================================================
//                                  FORWARD Operation Module
// Passes the second operand (DATA2) through unchanged to the output
// Used for MOV and LOADI instructions where no computation is needed
//============================================================================
module FORWARD(DATA2, RESULT);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] DATA2;       // 8-bit signed input data to forward
    output reg signed [7:0] RESULT; // 8-bit signed forwarded output
    
    //========== COMBINATIONAL FORWARD LOGIC ==========
    // Updates result whenever input changes
    always @(DATA2) begin
        #1 RESULT = DATA2;          // 1 time unit propagation delay
    end
endmodule

//============================================================================
//                                    ADD Operation Module
// Performs signed 8-bit addition of two operands
// Handles overflow naturally through Verilog's built-in arithmetic
//============================================================================
module ADD(DATA1, DATA2, RESULT);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] DATA1;       // 8-bit signed first operand
    input signed [7:0] DATA2;       // 8-bit signed second operand
    output reg signed [7:0] RESULT; // 8-bit signed sum result
   
    //========== COMBINATIONAL ADDITION LOGIC ==========
    // Updates result whenever either input changes
    always @(DATA1, DATA2) begin
        #2 RESULT = DATA1 + DATA2;  // 2 time unit delay for addition operation
    end
endmodule

//============================================================================
//                                    AND Operation Module
// Performs bitwise AND operation between two 8-bit signed operands
// Each bit position is ANDed independently
//============================================================================
module AND(DATA1, DATA2, RESULT);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] DATA1;       // 8-bit signed first operand
    input signed [7:0] DATA2;       // 8-bit signed second operand
    output reg signed [7:0] RESULT; // 8-bit signed AND result
    
    //========== COMBINATIONAL AND LOGIC ==========
    // Updates result whenever either input changes
    always @(DATA1, DATA2) begin
        #1 RESULT = DATA1 & DATA2;  // 1 time unit delay for AND operation
    end
endmodule

//============================================================================
//                                    OR Operation Module
// Performs bitwise OR operation between two 8-bit signed operands
// Each bit position is ORed independently
//============================================================================
module OR(DATA1, DATA2, RESULT);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] DATA1;       // 8-bit signed first operand
    input signed [7:0] DATA2;       // 8-bit signed second operand
    output reg signed [7:0] RESULT; // 8-bit signed OR result
    
    //========== COMBINATIONAL OR LOGIC ==========
    // Updates result whenever either input changes
    always @(DATA1, DATA2) begin
        #1 RESULT = DATA1 | DATA2;  // 1 time unit delay for OR operation
    end
endmodule

//============================================================================
//                                8-to-1 Multiplexer Module
// Selects one of 8 ALU operation results based on 3-bit SELECT signal
// Acts as the final output stage for the ALU, routing the chosen operation
//============================================================================
module mux(I0, I1, I2, I3, I4, I5, I6, I7, SELECT, RESULT);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] I0, I1, I2, I3, I4, I5, I6, I7; // 8 operation results
    input [2:0] SELECT;              // 3-bit operation selector
    output reg signed [7:0] RESULT;  // Selected operation result

    //========== COMBINATIONAL MUX LOGIC ==========
    // Updates result whenever any input or select signal changes
    always @(I0, I1, I2, I3, I4, I5, I6, I7, SELECT) begin
        case (SELECT) 
            3'b000: RESULT = I0;    // FORWARD operation output
            3'b001: RESULT = I1;    // ADD operation output
            3'b010: RESULT = I2;    // AND operation output
            3'b011: RESULT = I3;    // OR operation output
            3'b100: RESULT = I4;    // MULTIPLY operation output
            3'b101: RESULT = I5;    // LOGICAL SHIFT operation output
            3'b110: RESULT = I6;    // ARITHMETIC RIGHT SHIFT operation output
            3'b111: RESULT = I7;    // ROTATE RIGHT operation output
        endcase
    end 
endmodule

//============================================================================
//                                    ALU Top-Level Module
// Main ALU module that instantiates all operation units and output multiplexer
// Provides complete arithmetic and logic functionality for the CPU
//============================================================================
module alu(DATA1, DATA2, RESULT, SELECT, ZERO);
    //========== INPUT/OUTPUT DECLARATIONS ==========
    input signed [7:0] DATA1;       // 8-bit signed first operand (typically from register)
    input signed [7:0] DATA2;       // 8-bit signed second operand (from register or immediate)
    input [2:0] SELECT;             // 3-bit operation selector from control unit
    output signed [7:0] RESULT;     // 8-bit signed operation result
    output ZERO;                    // Zero flag for conditional branching (1 if result is zero)

    //========== INTERNAL WIRE DECLARATIONS ==========
    // Wires connecting each operation unit output to the multiplexer inputs
    wire signed [7:0] I0;           // FORWARD operation result
    wire signed [7:0] I1;           // ADD operation result
    wire signed [7:0] I2;           // AND operation result
    wire signed [7:0] I3;           // OR operation result
    wire signed [7:0] I4;           // MULTIPLY operation result
    wire signed [7:0] I5;           // LOGICAL SHIFT operation result
    wire signed [7:0] I6;           // ARITHMETIC RIGHT SHIFT operation result
    wire signed [7:0] I7;           // ROTATE RIGHT operation result

    //========== ALU OPERATION UNIT INSTANTIATIONS ==========
    
    // Basic operations (implemented locally)
    FORWARD uut(DATA2, I0);                     // Forward DATA2 unchanged
    ADD add_unit(DATA1, DATA2, I1);             // Signed addition
    AND and_unit(DATA1, DATA2, I2);             // Bitwise AND
    OR or_unit(DATA1, DATA2, I3);               // Bitwise OR
    
    // Complex operations (implemented in separate modules)
    multiply MUL(DATA1, DATA2, I4);             // Signed multiplication
    Logicalshift Lshift(DATA1, DATA2, I5);      // Logical left shift
    
    // Shift/Rotate operations using parameterized RIGHTshift module
    // DATA1: value to shift, DATA2: shift amount, I6/I7: result, last param: shift type
    RIGHTshift Rshift(DATA1, DATA2, I6, 2'b11);    // Arithmetic right shift (sign-extend)
    RIGHTshift RORshift(DATA1, DATA2, I7, 2'b00);  // Rotate right (circular shift)
    
    //========== OUTPUT MULTIPLEXER ==========
    // Selects final result based on operation selector
    mux mux_unit(I0, I1, I2, I3, I4, I5, I6, I7, SELECT, RESULT);
    
    //========== ZERO FLAG GENERATION ==========
    // Zero flag is set when the ALU result equals zero
    // Used by control unit for conditional branch instructions (BEQ/BNE)
    assign ZERO = (RESULT == 0) ? 1'b1 : 1'b0;

endmodule