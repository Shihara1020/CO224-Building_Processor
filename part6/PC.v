//============================================================================
//                                    Program Counter (PC) Unit Module
// Implements a 32-bit program counter with branch control logic
// Features:
// - Sequential execution (PC + 4)
// - Conditional branching based on ZERO flag and BRANCH control signals
// - Sign-extended 8-bit offset for branch target calculation
// - Synchronous reset capability
//============================================================================

module pc_unit(RESET,CLK,PC,BRANCH,ZERO,OFFSET);
    //========== INPUT PORT DECLARATIONS ==========
    input RESET;                    // Reset signal (active high) - sets PC to 0
    input CLK;                      // Clock signal for synchronous PC updates
    input [1:0] BRANCH;             // 2-bit branch control signal
                                    // [1]: Branch enable, [0]: Branch type selector
    input ZERO;                     // Zero flag from ALU for conditional branching
    input signed [7:0] OFFSET;      // 8-bit signed branch offset (word-aligned)

    //========== OUTPUT PORT DECLARATIONS ==========
    output reg [31:0] PC;           // 32-bit Program Counter (current instruction address)
    output signed [31:0] nextpc;    // Next PC value to be loaded on next clock cycle

    //========== INTERNAL WIRE DECLARATIONS ==========
    wire signed [31:0] PC_plus_four;    // Sequential PC value (current PC + 4)
    wire signed [31:0] BRANCH_TARGET;   // Calculated branch target address
    wire Branching;                     // Internal signal indicating branch condition met
    wire selector;                      // MUX selector signal for PC source selection
    wire signed [31:0] OFFSET_EXTENDED; // Sign-extended and shifted 32-bit offset

    //========== BRANCH CONTROL LOGIC ==========
    // Branching is true when ZERO flag matches the branch condition
    // BRANCH[1] = 1 enables branching, ZERO flag determines condition
    and and_gate1(Branching, ZERO, BRANCH[1]);
    
    // Selector determines final MUX control:
    // - If BRANCH[0] = 0: selector = Branching (branch on zero)
    // - If BRANCH[0] = 1: selector = ~Branching (branch on not zero)
    xor xor_gate1(selector, BRANCH[0], Branching);

    //========== ADDRESS CALCULATION LOGIC ==========
    // Sequential execution: next instruction is current PC + 4
    assign #1 PC_plus_four = PC + 4;
    
    // Sign-extend 8-bit offset to 32 bits and shift left by 2 (word alignment)
    // {{24{OFFSET[7]}}, OFFSET} creates sign extension
    assign OFFSET_EXTENDED = {{24{OFFSET[7]}}, OFFSET} << 2;
    
    // Branch target = (PC + 4) + sign_extended_offset
    // Uses PC+4 as base for relative addressing
    assign #2 BRANCH_TARGET = OFFSET_EXTENDED + (PC + 4);

    //========== MUX FOR PC SOURCE SELECTION ==========
    // Selects between sequential execution (PC+4) and branch target
    // selector = 0: choose PC_plus_four (sequential)
    // selector = 1: choose BRANCH_TARGET (branch taken)
    MUX_unit mux(PC_plus_four, BRANCH_TARGET, selector, nextpc);

    //========== SYNCHRONOUS PC UPDATE LOGIC ==========
    // PC is updated on positive clock edge
    always @(posedge CLK) begin
        if(RESET == 1'b1) begin 
            PC <= #1 0;        // Reset PC to address 0 with 1 time unit delay
        end
        else begin
            #1 PC = nextpc;     // Update PC with next calculated value
        end
    end

endmodule
//============================================================================
//                                    2-to-1 MUX Unit Module
// Simple 32-bit multiplexer for selecting between two data sources
// Used by PC unit to choose between sequential and branch target addresses
//============================================================================

module MUX_unit(DATA1, DATA2, SELECTOR, RESULT);

    //========== INPUT PORT DECLARATIONS ==========
    input [31:0] DATA1;     // First data input (selected when SELECTOR = 0)
    input [31:0] DATA2;     // Second data input (selected when SELECTOR = 1)
    input SELECTOR;         // Selection control signal

    //========== OUTPUT PORT DECLARATIONS ==========
    output [31:0] RESULT;   // Selected output data

    //========== MUX LOGIC ==========
    // Combinational logic: output depends immediately on inputs
    // SELECTOR = 0: RESULT = DATA1
    // SELECTOR = 1: RESULT = DATA2
    assign RESULT = (SELECTOR) ? DATA2 : DATA1;

endmodule





//============================================================================
//                                    PC Unit Testbench
// Testbench for verifying PC unit functionality
// Tests reset operation and sequential PC increment
//============================================================================
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