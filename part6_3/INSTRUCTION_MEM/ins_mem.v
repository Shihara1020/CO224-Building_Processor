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