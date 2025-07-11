//============================================================================
//                                       Register File Module
// 8-register file with dual read ports and single write port
// 8 registers (R0-R7), each storing 8-bit signed values
//============================================================================ 
`timescale  1ns/100ps

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET,HOLD);
    //========== INPUT PORT DECLARATIONS ==========
    input [2:0] OUT1ADDRESS;    // 3-bit address for first read port (selects R0-R7)
    input [2:0] OUT2ADDRESS;    // 3-bit address for second read port (selects R0-R7)  
    input [2:0] INADDRESS;      // 3-bit address for write port (selects R0-R7)
    input signed[7:0] IN;       // 8-bit signed data to write into selected register
    input CLK;                  // Clock signal for synchronous operations
    input RESET;                // Reset signal (active high) - clears all registers
    input WRITE;                // Write enable signal (active high)
    input HOLD;                 // Used to stall register updates 
    
    //========== OUTPUT PORT DECLARATIONS ==========
    output signed[7:0] OUT2;  // 8-bit signed data from second read port
    output signed[7:0] OUT1;  // 8-bit signed data from first read port
    
    //========== INTERNAL REGISTER DECLARATIONS ==========
    // 8 individual registers, each storing 8-bit signed values
    reg signed [7:0] registers [7:0];


    //========== SYNCHRONOUS WRITE AND RESET LOGIC ==========
    // Reset and Write operations are synchronous (triggered on positive clock edge)
    always @(posedge CLK) begin
        // If RESET is active, clear all registers
        if (RESET) begin
            #1
            for (integer i = 0; i < 8; i = i + 1) begin
                registers[i] = 8'd0;
            end
        end
    end

    always @(posedge CLK) begin
        // If WRITE is active, store data into selected register
        #0.001    
        if (WRITE && !RESET && !HOLD) begin
            #0.999
            registers[INADDRESS] = IN;
        end

    end
    
    // Asynchronous read logic 
    assign #2 OUT1 = registers[OUT1ADDRESS];
    assign #2 OUT2 = registers[OUT2ADDRESS];

    initial begin
		#5;
		$display("\n\t\t\t___________________________________________________");
		$display("\n\t\t\t\t\t CHANGE OF REGISTER VALUES");
		$display("\n\t\t\t___________________________________________________\n");
		$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
		$display("\t\t____________________________________________________________________");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
	end
        
endmodule
