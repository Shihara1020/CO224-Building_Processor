// ======================================================================
//                              ALU Module 
// Description: Complete ALU with multiple arithmetic and logic operations
// =======================================================================


// ------------------------------------------------
//           FORWARD Operation Module
// ------------------------------------------------
// Passes DATA2 to RESULT with 1 time unit delay

module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;
    output reg signed [7:0] RESULT;
    
    // Combinational logic with propagation delay
    always @(DATA2) begin
        #1 RESULT=DATA2;         // 1 time unit delay
    end
endmodule


// --------------------------------------------
//          ADD Operation Module
// ---------------------------------------------
// Computes DATA1 + DATA2 with 2 time units delay

module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    output reg signed  [7:0]RESULT;
   
    // Adder implementation 
    always @(DATA1,DATA2) begin
        #2 RESULT=DATA1+DATA2;    // 2 time unit delay
    end

endmodule


// -------------------------------------------
//          AND Operation Module
// --------------------------------------------
// Bitwise AND operation with 1 time unit delay

module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
    // Bitwise AND implementation
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1&DATA2;    // 1 time unit delay
    end

endmodule


// -------------------------------------------
//         OR Operation Module
// -------------------------------------------
// Bitwise OR operation with 1 time unit delay

module OR(DATA1,DATA2,RESULT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
   // Bitwise OR implementation
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1|DATA2;  // 1 time unit delay
    end
    

endmodule


// --------------------------------------
//         4:1 Multiplexer Module
// --------------------------------------
// Operation selector with zero-default safety

module mux(I0,I1,I2,I3,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3;
    input [2:0] SELECT;
    output reg signed[7:0] RESULT;

    // Update RESULT based on SELECT value
    always@(I0,I1,I2,I3,SELECT) begin
        case (SELECT) 
            3'b000:  RESULT=I0;             // FORWARD output  
            3'b001:  RESULT=I1;             // ADD ouput
            3'b010:  RESULT=I2;             // AND ouput
            3'b011:  RESULT=I3;             // OR output 
            default: RESULT=0;
        endcase
    end 


endmodule



// ===========================================
//             Main ALU Module
// ===========================================
// Operations:
//               000: Forward DATA2
//               001: Addition
//               010: Bitwise AND
//               011: Bitwise OR
//               others: Output 0
module alu(DATA1,DATA2,RESULT,SELECT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    input [2:0]SELECT;
    output signed[7:0]RESULT;

    // Internal wires for operation outputs
    wire signed [7:0]I0,I1,I2,I3;

    // Instantiate each operation module
    FORWARD uut(DATA2,I0);
    ADD add_unit(DATA1,DATA2,I1);
    AND and_unit(DATA1,DATA2,I2);
    OR or_unit(DATA1,DATA2,I3);
    // RESERVED res_unit();
    
    // Instantiate multiplexer to select one of the operation outputs
    mux mux_unit(I0,I1,I2,I3,SELECT,RESULT);

endmodule
