// module testbench;
//     reg signed[7:0] I0,I1;
//     reg select;
//     wire signed [7:0]OUTPUT; 

//     mux_unit mux(I0,I1,select,OUTPUT); 

//     initial begin
//        $monitor("I0: %0d I1: %0d  select:%0b OUTPUT:%0d",I0,I1,select,OUTPUT);

//        I0=8'd23;
//        I1=-8'd54;
//        select=1'b0;
//        #5;
//        select=1'b1;
//        #5;
//        $finish;

//     end


// endmodule


module mux_unit(DATA1,DATA2,select,OUTPUT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    input select;
    output signed[7:0]OUTPUT;

    assign OUTPUT= select ? DATA2 : DATA1;

endmodule