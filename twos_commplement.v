module testbench;
    reg signed[7:0] in;
    wire signed[7:0] out;

    twos_commplement uut(in,out);

    initial begin
       $monitor("");

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
    out=#1 (~in)+1;
end


endmodule 