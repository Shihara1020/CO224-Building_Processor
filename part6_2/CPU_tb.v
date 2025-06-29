// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`timescale  1ns/100ps
`include "CPU.v"
`include "DATA_MEMORY/DataMemory.v"
`include "DATA_MEMORY/cache.v"  


module cpu_tb;

    reg CLK, RESET; // Reset cpu
    reg RESET_MEM; //  Reset memory 
    wire [31:0] PC;
    reg [31:0] INSTRUCTION;
    
    //cache and alu
    wire [7:0]ADDRESS,WRITEDATA,READDATA;
    wire READ,WRITE,BUSYWAIT;

    //cache and memory
    wire [5:0]ADDRESS,
    wire [31:0]MEM_WRITEDATA,MEM_READDATA;
    wire MEM_READ,MEM_WRITE,MEM_BUSYWAIT;

    
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
    // CALL THE CACHE
    CACHE cache_unit(CLK,BUSYWAIT,READ,WRITE,WRITEDATA,READDATA,ADDRESS,RESET_MEM,MEM_BUSYWAIT,MEM_READ,MEM_WRITE,MEM_WRITEDATA,MEM_READDATA,MEM_ADDRESS)
    // Instanciate Data Memory
    data_memory data_memory_unit(CLK,RESET_MEM,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(3,cpu_tb,cpu_tb.mycpu.REGFILE.register0,cpu_tb.mycpu.REGFILE.register1,cpu_tb.mycpu.REGFILE.register2,cpu_tb.mycpu.REGFILE.register3,cpu_tb.mycpu.REGFILE.register4,cpu_tb.mycpu.REGFILE.register5,cpu_tb.mycpu.REGFILE.register6,cpu_tb.mycpu.REGFILE.register7);
        
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
        #500
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule