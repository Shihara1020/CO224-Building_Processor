// module pc_tb;
// reg CLK,RESET;
// wire [31:0]pc;

// pc_unit PCtest(RESET,CLK,pc);

// initial begin 
//     CLK=1'b1;
//     forever #4 CLK=~CLK;
// end

// initial begin
//     #15
//     RESET=1;
//     #4
//     RESET=0;
//     #50
//     $finish;
// end

// initial begin
//     $monitor("Time = %3d | reset =%d  | pc= %d\n ",$time,RESET,pc);
// end

// endmodule




module pc_unit(RESET,CLK,PC);
input RESET;
input CLK;
output reg [31:0] PC;
wire [31:0] nextpc;



always @(posedge CLK) begin
    if(RESET == 1'b1) begin 
        PC<= #1 0;
    end
    else begin
        PC<= #1 nextpc; 
    end
end

assign #1 nextpc=PC+4;

endmodule