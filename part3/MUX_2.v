module testbench;
    reg signed[7:0] I0,I1;
    reg select;
    wire signed [7:0]Y; 

    mux_unit mux(I0,I1,select,Y); 

    initial begin
       $monitor("I0: %0d I1: %0d  select:%0b Y:%0d",I0,I1,select,Y);

       I0=8'd23;
       I1=-8'd54;
       select=1'b0;
       #5;
       select=1'b1;
       #5;
       $finish;

    end


endmodule


module mux_unit(in0,in1,select,Y);
    input signed[7:0]in0;
    input signed[7:0]in1;
    input select;
    output signed[7:0]Y;

    assign Y= select ? in1 : in0;

endmodule