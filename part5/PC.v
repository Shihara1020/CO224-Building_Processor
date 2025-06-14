module pc_unit(RESET,CLK,PC,BRANCH,ZERO,JUMP,OFFSET,BNE);
    input RESET;
    input CLK;
    input BRANCH,ZERO,JUMP,BNE;
    input signed [7:0]OFFSET;

    output reg [31:0] PC;
    output signed [31:0]nextpc;

    wire signed [31:0] PC_plus_four;
    wire signed [31:0] BRANCH_TARGET;

    wire Branching,BNE_branch;
    wire selector;
    wire signed [31:0]OFFSET_EXTENDED;


    and and_gate1(Branching,ZERO,BRANCH);
    and and_gate2(BNE_branch,~ZERO,BNE);
    or  or_gate1(selector,JUMP,Branching,BNE_branch);

    assign #1 PC_plus_four=PC+4;
    assign OFFSET_EXTENDED= {{24{OFFSET[7]}}, OFFSET} << 2;

    assign #2 BRANCH_TARGET=OFFSET_EXTENDED+(PC+4);

    MUX_unit mux(PC_plus_four,BRANCH_TARGET,selector,nextpc);


    always @(posedge CLK) begin
        if(RESET == 1'b1) begin 
            PC<= #1 0;
        end
        else begin
            #1 PC= nextpc; 
        end
    end

endmodule

module MUX_unit(DATA1,DATA2,SELECTOR,RESULT);
    input [31:0]DATA1,DATA2;
    output [31:0]RESULT;
    input SELECTOR;

    assign RESULT=(SELECTOR)?DATA2:DATA1;
endmodule



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