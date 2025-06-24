
gcc CO224Assembler.c -o CO224Assembler
./generate_memory_image.sh sample_program.s


./generate_memory_image.sh SampleProgram/srl.s
iverilog -o CPUtest.vvp CPU_tb.v
vvp CPUtest.vvp
gtkwave cpu_wavedata.vcd
gtkwave cpu_wavedata.vcd Waveform/waveform.gtkw




iverilog -o test.vvp MUX2_1.v
vvp test.vvp