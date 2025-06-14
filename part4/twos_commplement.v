//============================================================================
//                        Two's Complement Converter Module
// Converts input number to its two's complement 
// Algorithm:   Two's complement = (~input) + 1 (invert bits and add 1)
//============================================================================

module twos_commplement(DATA_IN,DATA_OUT);
    input [7:0]DATA_IN;
    output reg signed[7:0] DATA_OUT;

    // Combinational logic block
    // Triggers whenever DATA_IN changes
    always @(DATA_IN) begin
        // Two's complement calculation with 1 delay
        // Step 1: Invert all bits (~DATA_IN)
        // Step 2: Add 1 to the inverted result
        // Result: Original number converted to its negative equivalent
        #1 DATA_OUT=(~DATA_IN)+1;
    end


endmodule 


// Testbench for Two's Complement Converter
// Tests conversion of positive numbers to their negative equivalents
// module testbench;
//     reg signed[7:0] in;
//     wire signed[7:0] out;

//     twos_commplement uut(in,out);

//     initial begin
//        $monitor("Time: %0t  Number : %d  Negative_number: %d",$time,in,out);
//        $dumpfile("two.vcd");
//        $dumpvars(0,testbench);

//        in=2;
//        #5
//        in=3;
//        #5;
//        in=8;
        
//     end


// endmodule

