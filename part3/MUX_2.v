//============================================================================
//                      2-to-1 Multiplexer Module
// Selects between two 8-bit signed inputs based on select signal
//============================================================================
module mux_unit(DATA1,DATA2,select,OUTPUT);
    input signed[7:0]DATA1;    // First data input (selected when select = 0)
    input signed[7:0]DATA2;    // Second data input (selected when select = 1)
    input select;              // Selection control signal
    output signed[7:0]OUTPUT;  // Multiplexer output
    

    // Multiplexer logic using conditional operator
    // When select = 0: OUTPUT = DATA1
    // When select = 1: OUTPUT = DATA2
    assign OUTPUT= select ? DATA2 : DATA1;

endmodule



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

