`include "DATA_MEMORY/wordselector.v"
`timescale  1ns/100ps
module CACHE(
    CLOCK,
    BUSYWAIT,
    READ,
    WRITE,
    WRITEDATA,
    READDATA,
    ADDRESS,
    RESET_CACHE,
    MEM_BUSYWAIT,
    MEM_READ,
    MEM_WRITE,
    MEM_WRITEDATA,
    MEM_READDATA,
    MEM_ADDRESS
);
    input CLOCK,READ,WRITE,RESET_CACHE;
    output reg BUSYWAIT;
    input [7:0] ADDRESS,WRITEDATA;
    output reg [7:0]READDATA;


    input MEM_BUSYWAIT;
    output reg MEM_READ,MEM_WRITE;
    output reg [31:0]MEM_WRITEDATA;
    output reg [5:0]MEM_ADDRESS;
    input [31:0]MEM_READDATA;

    

    //----------------Cache structure-------------------------
    reg valid_bit[7:0];     // valid bit array
    reg dirty_bit[7:0];     // dirty bit array
    reg [2:0] tag[7:0];     // tag array
    reg [31:0] data_array [7:0];   //data array

    // address break down
    wire [2:0]TARGET_TAG;
    wire [2:0]TARGET_INDEX;
    wire [1:0]TARGET_BLOCKOFFSET;
    assign TARGET_TAG=ADDRESS[7:5];
    assign TARGET_INDEX=ADDRESS[4:2];
    assign TARGET_BLOCKOFFSET=ADDRESS[1:0];

    // index cache data
    reg VALID, DIRTY;
    reg [2:0] CACHE_TAG;
    reg [31:0] DATABLOCK;


    //Detecting an incoming memory access
    always @(READ,WRITE)
    begin
        if(WRITE || READ) begin
            BUSYWAIT=1;
        end
    end

    // Artificial delay for accessing tag/data
    always @(*) begin
        #1 // Add 1 time unit delay
        VALID      = valid_bit[TARGET_INDEX];
        DIRTY      = dirty_bit[TARGET_INDEX];
        DATABLOCK  = data_array[TARGET_INDEX];
        CACHE_TAG  = tag[TARGET_INDEX];
    end

    
    //data word selector
    wire [7:0]outputdata;
    WORDSELECTOR instance2(DATABLOCK[7:0],DATABLOCK[15:8],DATABLOCK[23:16],DATABLOCK[31:24],TARGET_BLOCKOFFSET,outputdata);

    //check hit or not
    reg HIT;
    reg tag_comp;
    always @(*) 
        begin
            if(READ||WRITE)
                begin
                    #0.9 
                    tag_comp=~(TARGET_TAG^CACHE_TAG);
                    HIT= tag_comp && VALID && (READ || WRITE);
                end
        end


    //IF read and hit then send the data to CPU
    always @(*) begin
        if(READ && !WRITE && HIT) begin
            BUSYWAIT=0;
            READDATA=outputdata;
        end
        
    end


    //if write and hit,write the data to cache at the positive edge of the next cycle
    always @(posedge CLOCK) begin
        if(!READ && WRITE && HIT) begin
            dirty_bit[TARGET_INDEX]=1'b1;
            valid_bit[TARGET_INDEX]=1'b1;
            BUSYWAIT=0;

            case(TARGET_BLOCKOFFSET) 
                2'b00 :data_array[TARGET_INDEX][7:0]   = #1 WRITEDATA;
                2'b01 :data_array[TARGET_INDEX][15:8]  = #1 WRITEDATA;
                2'b10 :data_array[TARGET_INDEX][23:16] = #1 WRITEDATA;
                2'b11 :data_array[TARGET_INDEX][31:24] = #1 WRITEDATA;
            endcase
        end
    end


    //cashe and data memory state
    parameter 
    STATE_IDLE            = 3'b000,  // Idle: Waiting for a read/write request
    STATE_MEM_READ        = 3'b001,  // Memory Read: Fetch data from main memory
    STATE_MEM_WRITE       = 3'b010,  // Memory Write: Write data to main memory
    STATE_CACHE_UPDATE    = 3'b011;

    reg [2:0]state,next_state;

    always @(posedge CLOCK)  begin
        if(RESET_CACHE)
            state = STATE_IDLE;
        else
            state = next_state;
    end

    always @(*) begin
        case(state)
                STATE_IDLE:
                    if((READ||WRITE) && !DIRTY && !HIT)
                        next_state=STATE_MEM_READ;
                    else if((READ||WRITE) && DIRTY && !HIT)
                        next_state=STATE_MEM_WRITE;
                    else
                        next_state=STATE_IDLE;

                STATE_MEM_READ:
                    if (!MEM_BUSYWAIT)
                        next_state=STATE_CACHE_UPDATE;
                    else
                        next_state=STATE_MEM_READ;

                STATE_MEM_WRITE:
                    if (!MEM_BUSYWAIT)
                        next_state=STATE_MEM_READ;
                    else
                        next_state=STATE_MEM_WRITE;
                STATE_CACHE_UPDATE:
                        next_state=STATE_IDLE;
                
        endcase 
    end



    always @(state) begin
        case(state)
            STATE_IDLE:
                begin
                    MEM_READ=1'b0;
                    MEM_WRITE=1'b0;
                    MEM_ADDRESS=8'bx;
                    MEM_WRITEDATA=32'bx;
                    BUSYWAIT=0;
                end

            STATE_MEM_READ:
                begin
                    MEM_READ=1'b1;
                    MEM_WRITE=1'b0;
                    MEM_ADDRESS={TARGET_TAG,TARGET_INDEX};
                    MEM_WRITEDATA=32'bx;
                    BUSYWAIT=1;
                end 

            STATE_MEM_WRITE:
                begin
                    MEM_READ=1'b0;
                    MEM_WRITE=1'b1;
                    MEM_ADDRESS={CACHE_TAG,TARGET_INDEX};
                    MEM_WRITEDATA=DATABLOCK;
                    BUSYWAIT=1;
                end

            STATE_CACHE_UPDATE: 
                begin
                    MEM_READ = 1'b0;
                    MEM_WRITE = 1'b0;
                    MEM_ADDRESS = 6'bx;
                    MEM_WRITEDATA = 32'bx;
                    BUSYWAIT = 1;  // Keep CPU stalled during cache update

                    #1 // artificial delay for writing to cache
                    data_array[TARGET_INDEX] = MEM_READDATA;
                    tag[TARGET_INDEX] = TARGET_TAG;
                    valid_bit[TARGET_INDEX] = 1'b1;
                    dirty_bit[TARGET_INDEX] = 1'b0;
                    BUSYWAIT = 0;
                end

        endcase
    end

    //Reset cache
    integer i;
    always @(posedge CLOCK)
    begin
        if (RESET_CACHE)
        begin
            for (i=0;i<8; i=i+1) 
            begin                
                valid_bit[i] <= 0;
                dirty_bit[i] <= 0;
                // tag[i] <= 0;
                // data_array[i] <= 0;
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