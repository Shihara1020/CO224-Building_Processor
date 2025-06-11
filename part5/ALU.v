`include "multiplier.v"
`include "shift.v"
// SELECTION CODE:
//      FOEWARD - 000   (I0)
//      ADD     - 001   (I1)
//      AND     - 010   (I2)
//      OR      - 011   (I3)
//      MULT    - 100   (I4)
//      SL      - 101   (I5)
//      SRA     - 110   (I6)
//      ROR     - 111   (I7)



// FORWARD operation module
// Passes DATA2 to RESULT
module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;
    output reg signed [7:0] RESULT;
    
    // Update RESULT whenever DATA2 changes
    always @(DATA2) begin
        #1 RESULT=DATA2;         // 1 time unit delay
    end
endmodule



// ADD operation module
// Adds DATA1 and DATA2 and outputs the result
module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    output reg signed  [7:0]RESULT;
   
    // Update RESULT as the sum of DATA1 and DATA2 
    always @(DATA1,DATA2) begin
        #2 RESULT=DATA1+DATA2;    // 2 time unit delay
    end

endmodule



// AND operation module
// Performs bitwise AND between DATA1 and DATA2
module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
    // Update RESULT with bitwise AND of DATA1 and DATA2 
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1&DATA2;    // 1 time unit delay
    end

endmodule


// OR operation module
// Performs bitwise OR between DATA1 and DATA2
module OR(DATA1,DATA2,RESULT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
   // Update RESULT with bitwise OR of DATA1 and DATA2 
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1|DATA2;  // 1 time unit delay
    end
    

endmodule




// 4x1 multiplexer module
// Selects one of the 4 inputs based on SELECT signal
module mux(I0,I1,I2,I3,I4,I5,I6,I7,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3,I4,I5,I6,I7;
    input [2:0] SELECT;
    output reg signed[7:0] RESULT;

    // Update RESULT based on SELECT value
    always@(I0,I1,I2,I3,I4,I5,I6,I7,SELECT) begin
        case (SELECT) 
            3'b000:  RESULT=I0; // FORWARD output  
            3'b001:  RESULT=I1; // ADD ouput
            3'b010:  RESULT=I2; // AND ouput
            3'b011:  RESULT=I3; // OR output
            3'b100:  RESULT=I4; // multiplier output 
            3'b101:  RESULT=I5; // Leftshift
            3'b110:  RESULT=I6; // Arithmatic Right Shift
            3'b111:  RESULT=I7; // Rotate right
        endcase
    end 


endmodule

// ALU module
// Connects operation modules and uses multiplexer to select final result
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    input [2:0] SELECT;
    output signed [7:0]RESULT;
    output ZERO;

    // Internal wires for operation outputs
    wire signed [7:0]I0,I1,I2,I3,I4,I5,I6,I7;

    // Instantiate each operation module
    FORWARD uut(DATA2,I0);
    ADD add_unit(DATA1,DATA2,I1);
    AND and_unit(DATA1,DATA2,I2);
    OR or_unit(DATA1,DATA2,I3);
    multiply MUL(DATA1,DATA2,I4);
    LEFTshift Lshift(DATA1,DATA2,I5);
    //      SRA     - 110   (I6) - SETPIN-1
    //      ROR     - 111   (I7)  -SETPIN-0
    RIGHTshift Rshift(DATA1,DATA2,I6,1'b0);   //Right shift
    RIGHTshift RORshirt(DATA1,DATA2,I7,1'b1);  //Rotate right
    
    // Instantiate multiplexer to select one of the operation outputs
    mux mux_unit(I0,I1,I2,I3,I4,I5,I6,I7,SELECT,RESULT);
    //chech data1-dat2 is eqault to zero
    assign ZERO=(RESULT==0)?1'b1:1'b0;

endmodule
