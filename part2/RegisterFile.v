//GROUP-06
//Lab05- part2

// Testbench for reg_file module
module reg_file_tb;
    
    // Declare inputs 
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE;
    
    // Declare outputs 
    wire [7:0] REGOUT1, REGOUT2;
    
    // Instantiate the reg_file module
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    

    // Initial block for setting inputs and observing outputs
    initial
    begin
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("task2.vcd");
		$dumpvars(0, reg_file_tb);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6
        RESET = 1'b0;
        
        #2
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = -3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule




//============================================================================
//                                       Register File Module
// 8-register file with dual read ports and single write port
// 8 registers (R0-R7), each storing 8-bit signed values
//============================================================================ 

module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
    //========== INPUT PORT DECLARATIONS ==========
    input [2:0] OUT1ADDRESS;    // 3-bit address for first read port (selects R0-R7)
    input [2:0] OUT2ADDRESS;    // 3-bit address for second read port (selects R0-R7)  
    input [2:0] INADDRESS;      // 3-bit address for write port (selects R0-R7)
    input signed[7:0] IN;       // 8-bit signed data to write into selected register
    input CLK;                  // Clock signal for synchronous operations
    input RESET;                // Reset signal (active high) - clears all registers
    input WRITE;                // Write enable signal (active high)
    
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

        // If WRITE is active, store data into selected register    
        if (WRITE) begin
            #1
            registers[INADDRESS] = IN;
        end

    end
    
    // Asynchronous read logic 
    assign #2 OUT1 = registers[OUT1ADDRESS];
    assign #2 OUT2 = registers[OUT2ADDRESS];

    initial begin
		#5;
		$display("\n\t\t\t___________________________________________________");
		$display("\n\t\t\t CHANGE OF REGISTER CONTENT STARTING FROM TIME #5");
		$display("\n\t\t\t___________________________________________________\n");
		$display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
		$display("\t\t____________________________________________________________________");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d",registers[0],registers[1],registers[2],registers[3],registers[4],registers[5],registers[6],registers[7]);
	end
        
endmodule
