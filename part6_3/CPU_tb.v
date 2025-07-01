// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
`timescale  1ns/100ps
`include "CPU.v"
`include "DATA_MEMORY/DataMemory.v"
`include "DATA_MEMORY/cache.v"
`include "INSTRUCTION_MEM/ins_cache.v"
`include "INSTRUCTION_MEM/ins_mem.v"  


module cpu_tb;
    
    // Clock and Reset signals
    reg CLK, RESET;   // CPU Reset cpu singal
    reg RESET_MEM;    // Data memory Reset signal
    reg RESET_ICACHE; // Instruction cache reset signal
    
    // CPU signals
    wire [31:0] PC;           // Program Counter output from CPU
    wire [31:0] INSTRUCTION;  // Current instruction
    
    // Data Cache and ALU signals
    wire [7:0]DATAMEM_ADDRESS;     // Address for data memory access
    wire [7:0]DATAMEM_WRITEDATA;   // Data to write to memory 
    wire [7:0]DATAMEM_READDATA;    // Data read from memory
    wire READ,WRITE;               // Read/Write control signals
    wire BUSYWAIT;                 // Cache busy signal to CPU

    // Data Cache and Memory interface signals
    wire [5:0]MEM_ADDRESS;         // Memory address for cache-memory communication
    wire [31:0]MEM_WRITEDATA;      // Data written from cache to memory
    wire [31:0]MEM_READDATA;             // Data read from memory to cache
    wire MEM_READ,MEM_WRITE;       // Memory read/write control signals
    wire MEM_BUSYWAIT;             // Memory busy signal to cache


    // Instruction Cache signals
    
    wire INS_CACHE_BUSYWAIT;      // Instruction cache busy signal
    wire INS_MEM_BUSYWAIT;        // Instruction memory busy signal
    wire IM_READ;                 // Instruction memory read signal
    wire [127:0] IM_READ_INSTRUCTION; // Block of instructions read from memory
    wire [5:0] INSTRUCTION_MEM_ADDRESSS;  // Instruction memory address

        
    // Instanciate CPU
    // CPU handles instruction execution, register operations, and generates control signals
    cpu mycpu(PC, INSTRUCTION, CLK, RESET,READ,WRITE,BUSYWAIT,DATAMEM_ADDRESS,DATAMEM_WRITEDATA,DATAMEM_READDATA,INS_CACHE_BUSYWAIT); 

    // Instantiate Data Cache  
    CACHE cache_unit(CLK,BUSYWAIT,READ,WRITE,DATAMEM_WRITEDATA,DATAMEM_READDATA,DATAMEM_ADDRESS,RESET_MEM,MEM_BUSYWAIT,MEM_READ,MEM_WRITE,MEM_WRITEDATA,MEM_READDATA,MEM_ADDRESS);
    // Instanciate Data Memory
    // Main data memory that stores program data
    data_memory data_memory_unit(CLK,RESET_MEM,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);
     
    // Instantiate Instruction Cache
    // Cache for instructions 
    INS_CACHE ins_cache(CLK,RESET_ICACHE,INS_CACHE_BUSYWAIT,INSTRUCTION,PC[9:0],INS_MEM_BUSYWAIT,IM_READ,IM_READ_INSTRUCTION,INSTRUCTION_MEM_ADDRESSS);
    // Instantiate Instruction Memory
    // Main instruction memory that stores the program code
    INS_data_memory INS_mem_unit(CLK,IM_READ,INSTRUCTION_MEM_ADDRESSS,IM_READ_INSTRUCTION,INS_MEM_BUSYWAIT);
    





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
        RESET_ICACHE=1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET=1'b1;
        RESET_MEM=1'b1;
        RESET_ICACHE=1'b1;
        #4
        RESET=1'b0;
        RESET_MEM=1'b0;
        RESET_ICACHE=1'b0;
        // finish simulation after some time
        #2800
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule