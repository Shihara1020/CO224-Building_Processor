// Cache Module for Simple Processor
// Implements a direct-mapped cache with write-back policy
// Cache Configuration: 8 blocks, 4 bytes per block, 3-bit tags

`include "DATA_MEMORY/wordselector.v"
`timescale  1ns/100ps
module CACHE(
    // CPU 
    CLOCK,
    BUSYWAIT,
    READ,
    WRITE,
    WRITEDATA,
    READDATA,
    ADDRESS,
    RESET_CACHE,

    // Memory 
    MEM_BUSYWAIT,
    MEM_READ,
    MEM_WRITE,
    MEM_WRITEDATA,
    MEM_READDATA,
    MEM_ADDRESS
);

   // ----------------Port Declarations---------------------------


    input CLOCK,READ,WRITE,RESET_CACHE;
    output reg BUSYWAIT;           // Stalls CPU when cache is busy
    input [7:0] ADDRESS,WRITEDATA; //address and data from CPU
    output reg [7:0]READDATA;      // data to CPU


    input MEM_BUSYWAIT;               // Memory controller busy signal
    output reg MEM_READ, MEM_WRITE;   // Memory operation controls
    output reg [31:0]MEM_WRITEDATA;   // 32-bit data block to memory
    output reg [5:0]MEM_ADDRESS;      // 6-bit memory address (64 blocks max)
    input [31:0]MEM_READDATA;         // 32-bit data block from memory

    

    //-----------------Cache Structure------------------------------
    /*
    Direct-Mapped Cache :
    - 8 cache blocks (index: 3 bits)
    - 4 bytes per block (block offset: 2 bits)
    - 3-bit tags 
    */

    reg valid_bit[7:0];         // Valid bit array - indicates if cache line contains valid data
    reg dirty_bit[7:0];         // Dirty bit array - indicates if cache line has been modified
    reg [2:0] tag[7:0];         // Tag array - stores upper address bits for each cache line
    reg [31:0] data_array[7:0]; // Data array - stores 32-bit (4-byte) data blocks



    //-------------------Address Break Down----------------------------
    /*
    8-bit Address Breakdown:
    [7:5] - Tag (3 bits): Identifies which memory block this cache line represents
    [4:2] - Index (3 bits): Selects which cache line to use (0-7)
    [1:0] - Block Offset (2 bits): Selects which byte within the 4-byte block
    */
    wire [2:0]TARGET_TAG;
    wire [2:0]TARGET_INDEX;
    wire [1:0]TARGET_BLOCKOFFSET;

    assign TARGET_TAG=ADDRESS[7:5];
    assign TARGET_INDEX=ADDRESS[4:2];
    assign TARGET_BLOCKOFFSET=ADDRESS[1:0];

    //-------------------Index Cache Data------------------------------
    reg VALID, DIRTY;           // Current line's valid and dirty status
    reg [2:0] CACHE_TAG;        // Current line's stored tag
    reg [31:0] DATABLOCK;       // Current line's data block


    //------------------Detecting an incoming memory access-------------
    // Immediately assert BUSYWAIT when CPU initiates a memory access
    // This prevents CPU from proceeding until cache operation completes
    always @(READ,WRITE)
    begin
        if(WRITE || READ) begin
            BUSYWAIT=1;  // Stall CPU during cache access
        end
    end


    // ------------------Cache Reading----------------------------
    // Read cache line information with artificial access delay
    always @(*) begin
        #1 // Add 1 time unit delay
        VALID      = valid_bit[TARGET_INDEX];
        DIRTY      = dirty_bit[TARGET_INDEX];
        DATABLOCK  = data_array[TARGET_INDEX];   // Read data block
        CACHE_TAG  = tag[TARGET_INDEX];
    end

    
    //---------------------Data Word Selector----------------------
    wire [7:0]outputdata;
    WORDSELECTOR instance2(DATABLOCK[7:0],DATABLOCK[15:8],DATABLOCK[23:16],DATABLOCK[31:24],TARGET_BLOCKOFFSET,outputdata);


    //---------------------Check Hit or Not-------------------------
    reg HIT;
    reg tag_comp;
    always @(*) begin
        if(READ||WRITE)
            begin
                #0.9        // Tag comparison delay
                tag_comp=~(TARGET_TAG ^ CACHE_TAG); // Compare stored tag with target tag 
                HIT= tag_comp && VALID && (READ || WRITE);
            end
    end


    //------------------------Read Hit Handling----------------------
    //IF read and hit then send the data to CPU
    always @(*) begin
        if(READ && !WRITE && HIT) begin
            BUSYWAIT=0;            // Release CPU stall
            READDATA=outputdata;
        end
        
    end

    //------------------------Write Hit Handling----------------------
    //if write and hit,write the data to cache at the positive edge of the next cycle
    always @(posedge CLOCK) begin
        if(!READ && WRITE && HIT) begin
            // Mark line as dirty (modified) and valid
            dirty_bit[TARGET_INDEX]=1'b1;
            valid_bit[TARGET_INDEX]=1'b1;
            BUSYWAIT=0;  // Release CPU stall
            
            // Write data to appropriate byte within the 32-bit block
            case(TARGET_BLOCKOFFSET) 
                2'b00 :data_array[TARGET_INDEX][7:0]   = #1 WRITEDATA;
                2'b01 :data_array[TARGET_INDEX][15:8]  = #1 WRITEDATA;
                2'b10 :data_array[TARGET_INDEX][23:16] = #1 WRITEDATA;
                2'b11 :data_array[TARGET_INDEX][31:24] = #1 WRITEDATA;
            endcase
        end
    end


    //===================CACHE MISS STATE MACHINE======================
    /*
    State Machine for handling cache misses:
    - IDLE: Normal operation, waiting for requests
    - MEM_READ: Fetching data from main memory
    - MEM_WRITE: Writing dirty data back to memory
    - CACHE_UPDATE: Updating cache with fetched data
    */
    parameter 
        STATE_IDLE         = 3'b000,  // Waiting for CPU requests
        STATE_MEM_READ     = 3'b001,  // Reading from main memory
        STATE_MEM_WRITE    = 3'b010,  // Writing to main memory
        STATE_CACHE_UPDATE = 3'b011;  // Updating cache after memory read

    reg [2:0]state,next_state;
    
    // State register update on clock edge
    always @(posedge CLOCK)  begin
        if(RESET_CACHE)
            state = STATE_IDLE;          // Reset to idle state
        else
            state = next_state;          // Transition to next state
    end

    // Next state logic
    always @(*) begin
        case(state)
                STATE_IDLE:
                    if((READ||WRITE) && !DIRTY && !HIT)
                        next_state=STATE_MEM_READ;
                    else if((READ||WRITE) && DIRTY && !HIT)
                        next_state=STATE_MEM_WRITE;
                    else
                        next_state=STATE_IDLE;           // Hit or no operation

                STATE_MEM_READ:
                    if (!MEM_BUSYWAIT)      // Wait for memory read to complete
                        next_state=STATE_CACHE_UPDATE;   // Memory read done
                    else
                        next_state=STATE_MEM_READ;        // Keep waiting

                STATE_MEM_WRITE:
                    // Wait for memory write to complete
                    if (!MEM_BUSYWAIT)
                        next_state=STATE_MEM_READ;    // Write-back done, now read
                    else
                        next_state=STATE_MEM_WRITE;   // Keep waiting
                STATE_CACHE_UPDATE:
                        next_state=STATE_IDLE;        // Update done, return to idle
                
        endcase 
    end


    // STATE MACHINE OUTPUTS
    // Generate control signals based on current state
    always @(state) begin
        case(state)
            STATE_IDLE:
                begin
                    // Idle state: no memory operations
                    MEM_READ=1'b0;
                    MEM_WRITE=1'b0;
                    MEM_ADDRESS=8'bx;
                    MEM_WRITEDATA=32'bx;
                    BUSYWAIT=1'b0;    // CPU can proceed
                end

            STATE_MEM_READ:
                begin
                    // Reading new data from memory
                    MEM_READ=1'b1;          // Assert memory read
                    MEM_WRITE=1'b0;
                    MEM_ADDRESS={TARGET_TAG,TARGET_INDEX};
                    MEM_WRITEDATA=32'bx;
                    BUSYWAIT=1'b1;      // Keep CPU stalled
                end 

            STATE_MEM_WRITE:
                begin
                    // Writing dirty data back to memory
                    MEM_READ=1'b0;
                    MEM_WRITE=1'b1;             // Assert memory write
                    MEM_ADDRESS={CACHE_TAG,TARGET_INDEX};
                    MEM_WRITEDATA=DATABLOCK;
                    BUSYWAIT=1'b1;         // Keep CPU stalled
                end

            STATE_CACHE_UPDATE: 
                begin
                    // Update cache with newly fetched data
                    MEM_READ = 1'b0;
                    MEM_WRITE = 1'b0;
                    MEM_ADDRESS = 6'bx;
                    MEM_WRITEDATA = 32'bx;
                    BUSYWAIT = 1'b1;  // Keep CPU stalled 

                    #1 // artificial delay for writing to cache
                    // Install new data in cache
                    data_array[TARGET_INDEX] = MEM_READDATA; // Store fetched data
                    tag[TARGET_INDEX] = TARGET_TAG;          // Update tag
                    valid_bit[TARGET_INDEX] = 1'b1;          // Mark as valid 
                    dirty_bit[TARGET_INDEX] = 1'b0;
                    BUSYWAIT = 1'b0;    // Release CPU stall
                end

        endcase
    end

    //-----------------Reset cache----------------------------------
    integer i;
    always @(posedge CLOCK)
    begin
        if (RESET_CACHE)
        begin
            for (i=0;i<8; i=i+1) 
            begin                
                valid_bit[i] <= 0;  // Invalidate all cache lines
                dirty_bit[i] <= 0;  // Mark all lines as clean
                // tag and data arrays don't need reset as invalid lines ignore them
            end
        end
    end


    initial
    begin 
    $dumpfile("cpu_wavedata.vcd");
    for(i=0;i<8;i++)
        $dumpvars(1,valid_bit[i],tag[i],data_array[i],dirty_bit[i]);
    end
endmodule