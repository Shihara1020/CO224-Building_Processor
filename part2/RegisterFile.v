module reg_file_tb;
    
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin
        CLK = 1'b1;
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4  //4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6  //10
        RESET = 1'b0;
        
        #2  //12
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7  //19
        WRITEENABLE = 1'b0;
        
        #1  //20
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = 3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end


    integer i;
    initial begin
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("task2.vcd");
		$dumpvars(0, reg_file_tb);

        $dumpvars(1, myregfile.register0);
        $dumpvars(1, myregfile.register1);
        $dumpvars(1, myregfile.register2);
        $dumpvars(1, myregfile.register3);
        $dumpvars(1, myregfile.register4);
        $dumpvars(1, myregfile.register5);
        $dumpvars(1, myregfile.register6);
        $dumpvars(1, myregfile.register7);
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule




module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
    input [2:0]OUT1ADDRESS,OUT2ADDRESS,INADDRESS;
    input signed[7:0] IN;
    input CLK,RESET,WRITE;
    output reg signed[7:0]OUT2,OUT1;

    reg signed [7:0] register0,register1,register2,register3,register4,register5,register6,register7;


    always @(posedge CLK) begin
        if (RESET) begin
            #1
            register0 = 8'd0;
            register1 = 8'd0;
            register2 = 8'd0;
            register3 = 8'd0;
            register4 = 8'd0;
            register5 = 8'd0;
            register6 = 8'd0;
            register7 = 8'd0;
        end

        if (WRITE) begin
            #1
            case (INADDRESS)
                3'b000 :register0 = IN; 
                3'b001 :register1 = IN; 
                3'b010 :register2 = IN; 
                3'b011 :register3 = IN; 
                3'b100 :register4 = IN; 
                3'b101 :register5 = IN; 
                3'b110 :register6 = IN;
                3'b111 :register7 = IN;
            endcase
        end

    end

    always @(OUT1ADDRESS,OUT2ADDRESS,CLK) begin
        #2
        case (OUT1ADDRESS)
            3'b000 : OUT1 = register0; 
            3'b001 : OUT1 = register1; 
            3'b010 : OUT1 = register2; 
            3'b011 : OUT1 = register3;
            3'b100 : OUT1 = register4; 
            3'b101 : OUT1 = register5; 
            3'b110 : OUT1 = register6;
            3'b111 : OUT1 = register7; 
        endcase

        case (OUT2ADDRESS)
            3'b000 : OUT2 = register0; 
            3'b001 : OUT2 = register1; 
            3'b010 : OUT2 = register2; 
            3'b011 : OUT2 = register3;
            3'b100 : OUT2 = register4; 
            3'b101 : OUT2 = register5; 
            3'b110 : OUT2 = register6;
            3'b111 : OUT2 = register7; 
        endcase
        
    end
endmodule















// module testbench;
//     reg [2:0] READREG1,READREG2,WRITEREG;
//     reg [7:0] WRITEDATA;
//     reg CLOCK,RESET,WRITEENABLE;
//     wire[7:0] REGOUT1,REGOUT2;

//     reg_file uut(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLOCK,RESET);

//     always #5 CLOCK=~CLOCK;

//     initial begin
//         // Initialize
//         $monitor("REGOUT1: %d, REGOUT2: %d", REGOUT1, REGOUT2);
//         $dumpfile("task2.vcd");
//         $dumpvars(0,testbench);

//         CLOCK = 0;
//         RESET = 1;
//         WRITEENABLE = 0;
//         WRITEREG = 3'b000;
//         WRITEDATA = 8'd0;
//         READREG1 = 3'b000;
//         READREG2 = 3'b001;

//         #10 RESET = 0;

//         // Write to register 2
//         WRITEREG = 3'b010;
//         WRITEDATA = 8'd77;
//         WRITEENABLE = 1;
//         #10;

//         WRITEENABLE = 0;

//         // Read from register 2
//         READREG1 = 3'b010;
//         READREG2 = 3'b010;
//         #5;


//         #10 $finish;
//     end

    
// endmodule 