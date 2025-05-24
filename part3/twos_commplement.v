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



//two's complememnt unit
module twos_commplement(DATA_IN,DATA_OUT);
input [7:0]DATA_IN;
output reg signed[7:0] DATA_OUT;

always @(DATA_IN) begin
    #1 DATA_OUT=(~DATA_IN)+1;
end


endmodule 