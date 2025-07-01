./generate_memory_image.sh SAMPLEPROGRAM.s
iverilog -o CPUtest.vvp CPU_tb.v
vvp CPUtest.vvp
gtkwave cpu_wavedata.vcd WAVEFORM2.gtkw