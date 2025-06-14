//============================================================================
//                         Program Counter (PC) Module
// 32-bit program counter that increments by 4 on each clock cycle
//============================================================================


module pc_unit(RESET,CLK,PC);
    input RESET;            // Reset signal - when high, PC is set to 0
    input CLK;              // Clock signal - PC updates on positive edge
    output reg [31:0] PC;   // 32-bit program counter register
    wire [31:0] nextpc;     // Next PC value (current PC + 4)


    // Sequential logic block - PC register update
    // Triggered on positive edge of clock
    always @(posedge CLK) begin
        if(RESET == 1'b1) begin 
            PC<= #1 0;             // Synchronous reset: set PC to 0 with 1 delay
        end
        else begin
            PC<= #1 nextpc;       // Normal operation: load next PC value with 1 delay
        end
    end


    // Combinational logic - calculate next PC value
    // PC increments by 4 (standard for 32-bit word-addressed)
    assign #1 nextpc=PC+4;        // Add 4 to current PC with 1 delay

endmodule




// Testbench for Program Counter (PC) module
// Tests reset functionality and sequential PC increment behavior

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

