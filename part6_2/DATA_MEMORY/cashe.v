`include "DATA_MEMORY/check_hit.v"
`include "DATA_MEMORY/wordselector.v"


module CACHE(
    // cpu and cashe
    CLOCK,
    BUSYWAIT,
    READ,
    WRITE,
    WRITEDATA,
    READDATA,
    ADDRESS,
    RESET_CACHE;

    //cashe and data memory

    MCLOCK,
    MBUSYWAIT,
    MREAD,
    MWRITE,
    MWRITEDATA,
    MREADDATA,
    MADDRESS,
    RESET_MEMORY;
);
    output BUSYWAIT;
    input READ;
    input WRITE;
    input [7:0]WRITEDATA;
    input [7:0]ADDRESS;
    input RESET_CACHE;
    output [7:0]READDATA;


    input MBUSYWAIT;
    output READ;
    output WRITE;
    output [31:0]WRITEDATA;
    output [5:0]ADDRESS;
    output RESET_CASHE;
    input [31:0]READDATA;

    

    //declare the cache array
    reg valid_bit[7:0];
    reg dirty_bit[7:0];
    reg [2:0] tag[7:0];
    reg [31:0] data_array [7:0];


    //Detecting an incoming memory access
    always @(READ,WRITE)
    begin
        BUSYWAIT= (READ || WRITE)? 1 : 0;
    end


    //memory address splitting
    wire [2:0]TARGET_TAG;
    wire [2:0]TARGET_INDEX;
    wire [1:0]TARGET_BLOCKOFFSET;
    assign TARGET_TAG=ADDRESS[7:5];
    assign TARGET_INDEX=ADDRESS[4:2];
    assign TARGET_BLOCKOFFSET=ADDRESS[1:0];
    

    //cache
    //INDEX
    reg VALID, DIRTY;
    reg [2:0] CACHE_TAG;
    reg [31:0] DATABLOCK;

    always @(*) begin
        #1; // Add 1 time unit delay
        VALID      = valid_bit[TARGET_INDEX];
        DIRTY      = dirty_bit[TARGET_INDEX];
        DATABLOCK  = data_array[TARGET_INDEX];
        CACHE_TAG  = tag[TARGET_INDEX];
    end

    wire HIT;
    always @(*) begin
        if(READ||WRITE) begin
            #0.9
            HITORNOT instance(VALID,CACHE_TAG,TARGET_TAG,HIT);
        end
    end

    always @(READ,WRITE,HIT,DIRTY) begin
        if(HIT==1'b1) begin
            BUSYWAIT=1'b0;
            MREAD=1'b0;
            MWRITE=1'b0;
            MADDRESS={TARGET_TAG,TARGET_INDEX};
            MWRITEDATA=32'dx;
        end

        if((HIT==1'b0) && (READ||WRITE) && (DIRTY == 1'b0)) begin
            BUSYWAIT=1'b1;
            MREAD=1'b1;
            MWRITE=1'b0;
            MADDRESS={CACHE_TAG,TARGET_INDEX};
            MWRITEDATA=DATABLOCK;
        end 

        if((HIT==1'b0) && (READ||WRITE) && (DIRTY == 1'b1)) begin
            BUSYWAIT=1'b1;
            MREAD=1'b0;
            MWRITE=1'b1;
        end 
    end
    

    //data word selector
    
    wire [7:0]outputdata;
    WORDSELECTOR instance2(DATABLOCK[7:0],DATABLOCK[15:8],DATABLOCK[23:16],DATABLOCK[31:24],TARGET_BLOCKOFFSET,outputdata);

    //IF read and hit then send the data to CPU
    always @(*) begin
        if(READ && !WRITE && HIT) begin
            BUSYWAIT=1'b0;
            READDATA=outputdata;
        end
        
    end


    //if write and hit,write the data to cache at the positive edge of the next cycle
    always @(posedge CLOCK) begin
        if(!READ && WRITE && HIT) begin
            dirty_bit[TARGET_INDEX]=1'B1;
            valid_bit[TARGET_INDEX]=1'b1;
            BUSYWAIT=1'b0;

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
    STATE_CACHE_UPDATE    = 3'b011;  // Cache Update: Write fetched data into cache

    wire [2:0]state,next_state;

    always @(posedge CLOCK,RESET_CACHE)  begin
        if(RESET_CASHE)
            state=IDLE;
        else
            state=next_state;
        
    end

    always @(*) begin
        case(state)
                STATE_IDLE:
                    if((READ||WRITE) && !DIRTY && !HIT)
                        next_state=STATE_MEM_READ;
                    else if((READ||WRITE) && DIRTY && !HIT)
                        next_state=STATE_MEM_WRITE;
                    else:
                        next_state=STATE_IDLE;

                STATE_MEM_READ:
                    if (!MBUSYWAIT)
                        next_state=STATE_CACHE_UPDATE;
                    else
                        next_state=STATE_MEM_READ;

                STATE_MEM_WRITE:
                    if (!MBUSYWAIT)
                        next_state=STATE_CACHE_READ;
                    else
                        next_state=STATE_MEM_WRITE;

                STATE_CACHE_UPDATE:
                    next_state=STATE_IDLE;
        endcase
        
    end


    always @(state) begin
        STATE_IDLE:
            begin
               MREAD=1'b0;
               MWRITE=1'b0;
               MADDRESS=8'dx;
               MWRITEDATE=32'dx;
               BUSYWAIT=1'b0; 
            end
        STATE_MEM_READ:
               MREAD=1'b1;
               MWRITE=1'b0;
               MADDRESS={TARGET_TAG,TARGET_INDEX};
               MWRITEDATE=32'dx;
               BUSYWAIT=1'b1; 
        STATE_MEM_WRITE:
               MREAD=1'b0;
               MWRITE=1'b1;
               MADDRESS={CACHE_TAG,TARGET_INDEX};
               MWRITEDATE=DATABLOCK;
               BUSYWAIT=1'b1; 
        STATE_CACHE_UPDATE:
               MREAD=1'b0;
               MWRITE=1'b0;
               MADDRESS=8'dx;
               MWRITEDATE=32'dx;
               BUSYWAIT=1'b1; 
               
               #1
               {valid_bit[TARGET_INDEX],dirty_bit[TARGET_INDEX],tag[TARGET_INDEX],data_array[TARGET_INDEX]}={1'b1,1'b0,CACH_TAG,MREADDATA};
               
               BUSYWAIT=1'b0;
    end



    //Reset cache
    integer i;
    always @(posedge CLOCK)
    begin
        if (RESET_CACHE)
        begin
            for (i=0;i<8; i=i+1) begin                
                valid_bit[i] = 0;
                dirty_bit[i] = 0;
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