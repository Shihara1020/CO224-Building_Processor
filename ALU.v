module testbench;
    reg signed[7:0]OPERAND1,OPERAND2;
    reg[2:0]ALUOP;
    wire signed[7:0] ALURESULT;

    alu uut(OPERAND1,OPERAND2,ALURESULT,ALUOP);

    initial begin
        $monitor("TIME=%0t : OP1=%d OP2=%d ALUOP=%b RESULT=%d(%8b)", $time, OPERAND1, OPERAND2, ALUOP, ALURESULT,ALURESULT);
        

        //Test forward
        OPERAND1=8'd0;
        OPERAND2=8'd65;
        ALUOP  =3'b000;
        #10;

        //Test add
        OPERAND1=8'd45;
        OPERAND2=8'd30;
        ALUOP  =3'b001;
        #10;

        //Test AND
        OPERAND1=8'b00100110;
        OPERAND2=8'b00111010;
        ALUOP  =3'b010;
        #10;

        //Test OR
        ALUOP  =3'b011;
        #10;

        $finish;
        
    end
    
endmodule



module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;
    output signed [7:0] RESULT;

    assign RESULT=DATA2;
endmodule

module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    output signed  [7:0]RESULT;

    assign RESULT=DATA1+DATA2;

endmodule

module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed[7:0]DATA2;
    output signed[7:0]RESULT;

    assign RESULT=DATA1&DATA2;

endmodule

module OR(DATA1,DATA2,RESULT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    output signed[7:0]RESULT;

    assign RESULT=DATA1|DATA2;

endmodule

// module RESERVED();

// endmodule

module mux(I0,I1,I2,I3,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3;
    input [2:0] SELECT;
    output reg signed[7:0] RESULT;

    always@(I0,I1,I2,I3,SELECT) begin
        case (SELECT)
            3'b000: RESULT=I0;
            3'b001: RESULT=I1;
            3'b010: RESULT=I2;
            3'b011: RESULT=I3; 
            default: RESULT=0;
        endcase
    end 


endmodule

module alu(DATA1,DATA2,RESULT,SELECT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    input [2:0]SELECT;
    output signed[7:0]RESULT;
    output signed [7:0]I0,I1,I2,I3;


    FORWARD uut(DATA2,I0);
    ADD add_unit(DATA1,DATA2,I1);
    AND and_unit(DATA1,DATA2,I2);
    OR or_unit(DATA1,DATA2,I3);
    // RESERVED res_unit();

    mux mux_unit(I0,I1,I2,I3,SELECT,RESULT);

endmodule
