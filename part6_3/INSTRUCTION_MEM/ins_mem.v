`timescale  1ns/100ps
module INS_data_memory(
        clock,
        read,
        address,
        readinstruction,
        busywait
    );
    // Input/Output port declarations
    input  clock;
    input  read;             // Read enable signal for instruction fetch
    input[5:0]  address;     // 6-bit address 
    output reg [127:0]readinstruction; // 128-bit instruction data
    output reg   busywait;           // Signal indicating memory is busy

    //Declare memory array 1024x8-bits 
    reg [7:0] memory_array [1023:0];
    
    // Internal control signal for read access detection
    reg readaccess;

    // Initialization block - runs once at simulation start
    initial 
    begin
        busywait = 1'b0;
        readaccess = 1'b0;
         // Load instruction memory from external file
        $readmemb("./instr_mem.mem",memory_array,0,1023);

        // Sample program given below. You may hardcode your software program here, or load it from a file:
        //{memory_array[10'd3],  memory_array[10'd2],  memory_array[10'd1],  memory_array[10'd0]}  = 32'b00000000000001000000000000011001; // loadi 4 #25
        //{memory_array[10'd7],  memory_array[10'd6],  memory_array[10'd5],  memory_array[10'd4]}  = 32'b00000000000001010000000000100011; // loadi 5 #35
        //{memory_array[10'd11], memory_array[10'd10], memory_array[10'd9],  memory_array[10'd8]}  = 32'b00000010000001100000010000000101; // add 6 4 5
        //{memory_array[10'd15], memory_array[10'd14], memory_array[10'd13], memory_array[10'd12]} = 32'b00000000000000010000000001011010; // loadi 1 90
        //{memory_array[10'd19], memory_array[10'd18], memory_array[10'd17], memory_array[10'd16]} = 32'b00000011000000010000000100000100; // sub 1 1 4 
    end
    
    // Combinational logic to detect instruction fetch requests
    // Responds immediately to changes in read signal
    always @(read) begin
        busywait = (read) ? 1 : 0;
        readaccess = (read) ? 1 : 0;
    end

     // Sequential logic for instruction memory read operations
    // Operations are synchronized to the positive edge of clock
    always @(posedge clock)
    begin
        if(readaccess)
        begin
            // First 32-bit word
            readinstruction[7:0]     = #40 memory_array[{address,4'b0000}];
            readinstruction[15:8]    = #40 memory_array[{address,4'b0001}];
            readinstruction[23:16]   = #40 memory_array[{address,4'b0010}];
            readinstruction[31:24]   = #40 memory_array[{address,4'b0011}];

            // Second 32-bit word
            readinstruction[39:32]   = #40 memory_array[{address,4'b0100}];
            readinstruction[47:40]   = #40 memory_array[{address,4'b0101}];
            readinstruction[55:48]   = #40 memory_array[{address,4'b0110}];
            readinstruction[63:56]   = #40 memory_array[{address,4'b0111}];

            // Third 32-bit word
            readinstruction[71:64]   = #40 memory_array[{address,4'b1000}];
            readinstruction[79:72]   = #40 memory_array[{address,4'b1001}];
            readinstruction[87:80]   = #40 memory_array[{address,4'b1010}];
            readinstruction[95:88]   = #40 memory_array[{address,4'b1011}];

            // Fourth 32-bit word
            readinstruction[103:96]  = #40 memory_array[{address,4'b1100}];
            readinstruction[111:104] = #40 memory_array[{address,4'b1101}];
            readinstruction[119:112] = #40 memory_array[{address,4'b1110}];
            readinstruction[127:120] = #40 memory_array[{address,4'b1111}];

            // Clear control signals after operation completes
            busywait = 0;
            readaccess = 0;
        end
    end
endmodule