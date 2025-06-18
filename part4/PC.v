// Program Counter (PC) Unit Module
// Handles PC increment, branching, and jumping
module pc_unit(RESET,CLK,PC,BRANCH,ZERO,JUMP,OFFSET);
    input RESET;           // Reset signal
    input CLK;             // Clock signal
    input BRANCH,ZERO,JUMP; // Control signals
    input signed [7:0]OFFSET; // Branch offset
    
    output reg [31:0] PC;           // Current program counter
    output signed [31:0]nextpc;     // Next PC value
    
    wire signed [31:0] PC_plus_four;    // PC + 4
    wire signed [31:0] BRANCH_TARGET;   // Branch target address
    
    wire Branching;                     // Branch condition met
    wire selector;                      // MUX selector
    wire signed [31:0]OFFSET_EXTENDED;  // Sign-extended offset
    
    // Branch condition: branch when ZERO flag is set AND BRANCH signal is active
    assign Branching=ZERO&BRANCH;
    
    // Select branch/jump target when jumping or branching
    assign selector=JUMP|Branching;
    
    // Calculate PC + 4 with 1 time unit delay
    assign #1 PC_plus_four=PC+4;
    
    // Sign extend 8-bit offset to 32-bit and shift left by 2 - word alignment
    assign OFFSET_EXTENDED= {{24{OFFSET[7]}}, OFFSET} << 2;
    
    // Calculate branch target address with 2 time unit delay
    assign #2 BRANCH_TARGET=OFFSET_EXTENDED+(PC+4);
    
    // MUX to select between PC+4 and branch target
    MUX_unit mux(PC_plus_four,BRANCH_TARGET,selector,nextpc);
    
    // Sequential logic for PC update
    always @(posedge CLK) begin
        if(RESET == 1'b1) begin 
            PC<= #1 0;        // Reset PC to 0 with delay
        end
        else begin
            #1 PC= nextpc;    // Update PC with next value
        end
    end
endmodule

// 2-to-1 Multiplexer Unit
// Selects between two 32-bit inputs based on selector
module MUX_unit(DATA1,DATA2,SELECTOR,RESULT);
    input [31:0]DATA1,DATA2;  
    output [31:0]RESULT;      
    input SELECTOR;          
    
    // Select DATA2 when SELECTOR is high, otherwise DATA1
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

