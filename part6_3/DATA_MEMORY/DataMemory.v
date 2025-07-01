
`timescale  1ns/100ps
module data_memory(
        clock,
        reset,
        read,
        write,
        address,
        writedata,
        readdata,
        busywait
    );
    // Input/Output port declarations
    input  clock;
    input  reset;
    input  read;
    input  write;
    input[5:0]  address;
    input[31:0] writedata;
    output reg [31:0]readdata;
    output reg   busywait;

    //Declare memory array 256x8-bits 
    reg [7:0] memory_array [255:0];

    //Detecting an incoming memory access
    reg readaccess, writeaccess;
    always @(read, write)
    begin
        busywait = (read || write)? 1 : 0;
        readaccess = (read && !write)? 1 : 0;
        writeaccess = (!read && write)? 1 : 0;
    end

    // Operations are synchronized to the positive edge of clock
    always @(posedge clock)
    begin
        // Handle memory read operation
        if(readaccess)
        begin
            // Read 32-bit word by accessing 4 consecutive byte locations
            // Each word occupies 4 bytes: address concatenated with 2-bit offset
            // #40 adds 40ns delay to simulate memory access time
            readdata[7:0] = #40 memory_array[{address,2'b00}];
            readdata[15:8] = #40 memory_array[{address,2'b01}];
            readdata[23:16] = #40 memory_array[{address,2'b10}];
            readdata[31:24] = #40 memory_array[{address,2'b11}];
            // Clear control signals after operation completes
            busywait = 0;
            readaccess = 0;
        end
        // Handle memory write operation
        if(writeaccess)
        begin
            // Write 32-bit word by storing in 4 consecutive byte locations
            // Split writedata into 4 bytes and store with simulated access delay
            memory_array[{address,2'b00}] = #40 writedata[7:0];
            memory_array[{address,2'b01}] = #40 writedata[15:8];
            memory_array[{address,2'b10}] = #40 writedata[23:16];
            memory_array[{address,2'b11}] = #40 writedata[31:24];
            // Clear control signals after operation completes
            busywait = 0;
            writeaccess = 0;
        end
    end

    integer i;

    //Reset memory
    always @(posedge reset)
    begin
        if (reset)
        begin
            for (i=0;i<256; i=i+1)
                memory_array[i] = 0;
            
            // Reset all control signals to idle state
            busywait = 0;
            readaccess = 0;
            writeaccess = 0;
        end
    end

    initial begin
        $dumpfile("cpu_wavedata.vcd");
        for (i = 0; i<256; i++) begin
            $dumpvars(1, memory_array[i]);
        end
    end

endmodule