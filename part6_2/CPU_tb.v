// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
`timescale  1ns/100ps
`include "CPU.v"
`include "DATA_MEMORY/DataMemory.v"
`include "DATA_MEMORY/cache.v"  


module cpu_tb;
    // Clock and reset signals
    reg CLK, RESET; // Clock signal and CPU reset
    reg RESET_MEM;  // Reset memory

    // CPU signals
    wire [31:0] PC;  // Program Counter
    reg [31:0] INSTRUCTION; // 32-bit instruction word 
    
    //Cache and Alu singals
    wire [7:0]ADDRESS;       // Address for data memory access
    wire [7:0]WRITEDATA;     // Data to write to memory 
    wire [7:0]READDATA;      // Data read from memory
    wire READ,WRITE,BUSYWAIT;

    //Cache and Memory singals
    wire [5:0]MEM_ADDRESS;    // Memory address for cache-memory communication
    wire [31:0]MEM_WRITEDATA; // Data written from cache to memory
    wire [31:0]MEM_READDATA;  // Data read from memory to cache
    wire MEM_READ,MEM_WRITE;  // Memory read/write control signals
    wire MEM_BUSYWAIT;        // Memory busy signal to cache

    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory

    reg[7:0]instr_mem[1023:0];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
        
    always @(PC) begin
        #2
        INSTRUCTION={instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC]};
    end
        
    initial
    begin       
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        $readmemb("instr_mem.mem", instr_mem);
    end
    
    
    // Instanciate CPU
    cpu mycpu(PC, INSTRUCTION, CLK, RESET,READ,WRITE,BUSYWAIT,ADDRESS,WRITEDATA,READDATA); 
    // Instantiate the cache module
    CACHE cache_unit(CLK,BUSYWAIT,READ,WRITE,WRITEDATA,READDATA,ADDRESS,RESET_MEM,MEM_BUSYWAIT,MEM_READ,MEM_WRITE,MEM_WRITEDATA,MEM_READDATA,MEM_ADDRESS);
    // Instantiate the data memory 
    data_memory data_memory_unit(CLK,RESET_MEM,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
        for (integer i = 0; i < 8; i = i + 1) 
        begin
                $dumpvars(3,cpu_tb,cpu_tb.mycpu.REGFILE.registers[i]);
            end
		
        
        CLK = 1'b0;
        RESET = 1'b0;
        RESET_MEM=1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET=1'b1;
        RESET_MEM=1'b1;
        #4
        RESET=1'b0;
        RESET_MEM=1'b0;
        // finish simulation after some time
        #2000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule