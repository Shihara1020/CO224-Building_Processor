module testbench;
    reg signed[7:0] in;
    wire signed[7:0] out;

    twos_commplement uut(in,out);

    initial begin
       $monitor("Time: %0t  Number : %d  Negative_number: %d",$time,in,out);
       $dumpfile("two.vcd");
       $dumpvars(0,testbench);

       in=2;
       #5
       in=3;
       #5;
       in=8;
        
    end


endmodule


module twos_commplement(in,out);
input [7:0]in;
output reg signed[7:0] out;

always @(in) begin
    #1 out=(~in)+1;
end


endmodule 