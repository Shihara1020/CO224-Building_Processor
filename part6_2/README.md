./generate_memory_image.sh SAMPLEPROGRAM.s
iverilog -o CPUtest.vvp CPU_tb.v
vvp CPUtest.vvp
gtkwave cpu_wavedata.vcd WAVEFORM2.gtkw


//loadi 0 0x09    
//loadi 1 0x01    
//swd 0 1       
//swi 1 0x00    
//lwd 2 1       
//lwd 3 1       
//sub 4 0 1     
//swi 4 0x07
//lwi 5 0x07   
//swi 4 0x20
//lwi 6 0x20