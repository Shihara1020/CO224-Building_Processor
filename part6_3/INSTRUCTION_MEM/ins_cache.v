`include "INSTRUCTION_MEM/instructionselector.v"
`timescale  1ns/100ps
module INS_CACHE(
        CLOCK,
        RESET_ICACHE,
        BUSYWAIT,
        NEXT_INSTRUCTION,
        ADDRESS,
        IM_BUSYWAIT,
        IM_READ,
        IM_READ_INSTRUCTION,
        IM_ADDRESS
);
    // CPU Signals
    input CLOCK, RESET_ICACHE;          // Clock and reset signals
    output reg BUSYWAIT;                // Signal to stall CPU during cache miss
    input [9:0] ADDRESS;                // 10-bit instruction address from CPU
    output reg [31:0] NEXT_INSTRUCTION; // 32-bit instruction output to CPU


    // Memory Signals  
    input IM_BUSYWAIT;                  // Busy signal from instruction memory
    output reg IM_READ;                 // Read enable to instruction memory
    input [127:0] IM_READ_INSTRUCTION;  // 128-bit instruction block from memory
    output reg [5:0] IM_ADDRESS;        // 6-bit address to instruction memory

    

    //--------------------------------Cache Structure----------------------------
    // Cache arrays for 8 cache blocks
    reg valid_bit[7:0];     // Valid bit array
    reg [2:0] tag[7:0];     // Tag array
    reg [127:0] instruction_array [7:0];   //Data array
    
    // Assert BUSYWAIT immediately when address changes 
    always @(ADDRESS) begin
        BUSYWAIT=1'b1;
    end



    //----------------Address Decoding-------------------------
    // Split 10-bit address into tag, index, and block offset
    wire [2:0] target_tag, target_index;
    wire [3:0] block_offset;

    assign target_tag     = ADDRESS [9:7];
    assign target_index   = ADDRESS [6:4];
    assign block_offset   = ADDRESS [3:0];


    //----------------Cache Access Logic-------------------------
    reg valid;
    reg [2:0] cache_tag;
    reg [127:0] instruction_set;
    
     // Read cache data based on index 
    always @(*) begin
        #1
        valid=valid_bit[target_index];
        cache_tag=tag[target_index];
        instruction_set=instruction_array[target_index];
    end
    

    //----------------Hit/Miss Detection-------------------------
    reg tag_comp;
    reg hit;
     // Compare tags and determine hit/miss
    always @(*) begin
        #0.9
        tag_comp= ~(cache_tag ^ target_tag);
        hit = valid && tag_comp;
    end
    
    // Instruction selector 
    // block_offset[3:2] selects which 32-bit word
    wire [31:0] select_instruction;
    INSTSELECTOR INSTSELECTOR_UNIT(instruction_set[31:0],instruction_set[63:32], instruction_set[95:64], instruction_set[127:96], block_offset[3:2], select_instruction);
     
    
    //----------------Cache Hit---------------------------------
    always @(hit,select_instruction) begin
        if (hit) begin
            BUSYWAIT = 0;        // Clear busy signal
            IM_READ = 0;         // Disable memory read
            NEXT_INSTRUCTION = select_instruction;  // Provide instruction to CPU
        end  
    end
    

    
    //----------------Cache Update-------------------------
    always @(IM_BUSYWAIT) begin
    #1
    if (!IM_BUSYWAIT) begin
      {valid_bit[target_index], tag[target_index], instruction_array[target_index]} = {1'b1, target_tag, IM_READ_INSTRUCTION};     
    end  
  end



    //----------------Finite State Machine for Cache Control-------------------------
    // State definitions
    parameter IDLE = 3'b000,     // Cache idle, serving hits
              MEM_READ = 3'b001; // Cache miss, reading from memory
    reg [2:0] state, next_state;
    
    // Sequential state update
    always @(posedge CLOCK)
    begin
        if(RESET_ICACHE)
            state = IDLE;
        else
            state = next_state;
    end


    // combinational next state logic
    always @(*) begin
        case (state)
            IDLE:
                if (hit)  
                    next_state = IDLE;    // Stay in IDLE on cache hit
                else
                    next_state = MEM_READ;  // Go to MEM_READ on cache miss
            
            MEM_READ:
                if (IM_BUSYWAIT)
                    next_state = MEM_READ; // Stay in MEM_READ while memory is busy
                else    
                    next_state = IDLE;     // Return to IDLE 
        endcase
    end

    //----------------State-based Control Signal Generation-------------------------
    // Generate control signals based on current state
    always @(state) begin
        case (state)
            IDLE:
                begin
                    IM_READ = 1'b0;              // No memory read in idle state
                    IM_ADDRESS = 6'bx;
                end

            MEM_READ:
                begin
                    IM_READ = 1'b1;          // Enable memory read
                    IM_ADDRESS = {target_tag, target_index};
                    BUSYWAIT = 1'b1;         // Keep CPU stalled
                end 
        endcase
    end

  
    integer i;
    always @(posedge CLOCK)
    begin
        if (RESET_ICACHE)
            begin
            for (i=0;i<8; i=i+1) begin                
                valid_bit[i] = 0;      
            end
            end
    end

    initial
    begin 
        $dumpfile("cpu_wavedata.vcd");
        for(i=0;i<8;i++)
            $dumpvars(1,valid_bit[i],tag[i],instruction_array[i]);
    end

endmodule