module pc_unit(RESET,CLK,PC);
input RESET;
input CLK;
output reg [31:0] PC;
wire [31:0] nextpc;

always @(posedge CLK) begin
    if(RESET == 1'b1) begin 
        pc<=0;
    end

    else begin
        pc<=nextpc; 
    end
end

assign nextpc=pc+4;

endmodule