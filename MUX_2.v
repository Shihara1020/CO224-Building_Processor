module mux(in1,in2,select,Y);
    input [7:0]in1;
    input [7:0]in2;
    input select;
    output [7:0]Y;

    assign Y= select?int1:in2;

endmodule