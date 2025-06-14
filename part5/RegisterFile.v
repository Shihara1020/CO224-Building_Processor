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
    output reg signed[7:0] OUT2;  // 8-bit signed data from second read port
    output reg signed[7:0] OUT1;  // 8-bit signed data from first read port
    
    //========== INTERNAL REGISTER DECLARATIONS ==========
    // 8 individual registers, each storing 8-bit signed values
    reg signed [7:0] register0;   // Register R0 (address 000)
    reg signed [7:0] register1;   // Register R1 (address 001)
    reg signed [7:0] register2;   // Register R2 (address 010)
    reg signed [7:0] register3;   // Register R3 (address 011)
    reg signed [7:0] register4;   // Register R4 (address 100)
    reg signed [7:0] register5;   // Register R5 (address 101)
    reg signed [7:0] register6;   // Register R6 (address 110)
    reg signed [7:0] register7;   // Register R7 (address 111)


    //========== SYNCHRONOUS WRITE AND RESET LOGIC ==========
    // Reset and Write operations are synchronous (triggered on positive clock edge)
    always @(posedge CLK) begin
        // If RESET is active, clear all registers
        if (RESET) begin
            #1
            register0 = 8'd0;
            register1 = 8'd0;
            register2 = 8'd0;
            register3 = 8'd0;
            register4 = 8'd0;
            register5 = 8'd0;
            register6 = 8'd0;
            register7 = 8'd0;
        end

        // If WRITE is active, store data into selected register    
        if (WRITE) begin
            #1
            case (INADDRESS)
                3'b000 :register0 = IN; 
                3'b001 :register1 = IN; 
                3'b010 :register2 = IN; 
                3'b011 :register3 = IN; 
                3'b100 :register4 = IN; 
                3'b101 :register5 = IN; 
                3'b110 :register6 = IN;
                3'b111 :register7 = IN;
            endcase
        end

    end
    
     // Asynchronous read logic 
    always @(OUT1ADDRESS,OUT2ADDRESS,CLK) begin
        #2  // #2 time dalay 
        case (OUT1ADDRESS)
            3'b000 : OUT1 = register0; 
            3'b001 : OUT1 = register1; 
            3'b010 : OUT1 = register2; 
            3'b011 : OUT1 = register3;
            3'b100 : OUT1 = register4; 
            3'b101 : OUT1 = register5; 
            3'b110 : OUT1 = register6;
            3'b111 : OUT1 = register7; 
        endcase

        case (OUT2ADDRESS)
            3'b000 : OUT2 = register0; 
            3'b001 : OUT2 = register1; 
            3'b010 : OUT2 = register2; 
            3'b011 : OUT2 = register3;
            3'b100 : OUT2 = register4; 
            3'b101 : OUT2 = register5; 
            3'b110 : OUT2 = register6;
            3'b111 : OUT2 = register7; 
        endcase
        
    end
endmodule
