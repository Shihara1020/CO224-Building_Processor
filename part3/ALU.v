// the operation of forward
module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;
    output reg signed [7:0] RESULT;
    
    always @(DATA2) begin
        //#1 RESULT=DATA2;
        RESULT=DATA2;
    end

endmodule



module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    output reg signed  [7:0]RESULT;
    
    always @(DATA1,DATA2) begin
        // #2 RESULT=DATA1+DATA2;
        RESULT=DATA1+DATA2;
    end

endmodule



module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;

    always @(DATA1,DATA2) begin
        // #1 RESULT=DATA1&DATA2;
        RESULT=DATA1&DATA2;
    end

endmodule



module OR(DATA1,DATA2,RESULT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;

    always @(DATA1,DATA2) begin
        // #1 RESULT=DATA1|DATA2;
        RESULT=DATA1|DATA2;
    end
    

endmodule

// module RESERVED();

// endmodule



module mux(I0,I1,I2,I3,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3;
    input [2:0] SELECT;
    output reg signed[7:0] RESULT;

    always@(I0,I1,I2,I3,SELECT) begin
        case (SELECT)
            3'b000: #1 RESULT=I0;
            3'b001: #2 RESULT=I1;
            3'b010: #1 RESULT=I2;
            3'b011: #1 RESULT=I3; 
            default: RESULT=0;
        endcase
    end 


endmodule

module alu(DATA1,DATA2,RESULT,SELECT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    input [2:0]SELECT;
    output signed[7:0]RESULT;

    
    wire signed [7:0]I0,I1,I2,I3;


    FORWARD uut(DATA2,I0);
    ADD add_unit(DATA1,DATA2,I1);
    AND and_unit(DATA1,DATA2,I2);
    OR or_unit(DATA1,DATA2,I3);
    // RESERVED res_unit();

    mux mux_unit(I0,I1,I2,I3,SELECT,RESULT);

endmodule
