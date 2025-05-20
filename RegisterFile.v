module testbench;
reg [2:0] READREG1,READREG2,WRITEREG;
reg [7:0] WRITEDATA;
reg CLOCK,RESET,WRITEENABLE;
wire[7:0] REGOUT1,REGOUT2;

reg_file(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLOCK,RESET);

laways #5 CLOCK=~CLOCK;

initial begin
    // Initialize
    CLOCK = 0;
    RESET = 1;
    WRITEENABLE = 0;
    WRITEREG = 3'b000;
    WRITEDATA = 8'd0;
    READREG1 = 3'b000;
    READREG2 = 3'b001;

    #10 RESET = 0;

    // Write to register 2
    WRITEREG = 3'b010;
    WRITEDATA = 8'd77;
    WRITEENABLE = 1;
    #10;

    WRITEENABLE = 0;

    // Read from register 2
    READREG1 = 3'b010;
    READREG2 = 3'b010;
    #5;

    $display("REGOUT1: %d, REGOUT2: %d", REGOUT1, REGOUT2);

    #10 $finish;
end

    
endmodule 




module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
    input [2:0]OUT1ADDRESS,OUT2ADDRESS,INADDRESS;
    input [7:0] IN;
    input CLK,RESET,WRITE;
    output reg [7:0]OUT2,OUT1;

    reg [7:0] register0,register1,register2,register3,register4,register5,register6,register7;


    always @(posedge CLK) begin
        if (WRITE==1'b1) begin
            #1;
            case (INADDRESS)
                3'b000 :register0 <= IN; 
                3'b001 :register1 <= IN; 
                3'b010 :register2 <= IN; 
                3'b011 :register3 <= IN; 
                3'b100 :register4 <= IN; 
                3'b101 :register5 <= IN; 
                3'b110 :register6 <= IN;
                3'b111 :register7 <= IN;
            endcase
        end

        if (RESET==1'b1) begin
            #1;
            register0 <= 0;
            register1 <= 0;
            register2 <= 0;
            register3 <= 0;
            register4 <= 0;
            register5 <= 0;
            register6 <= 0;
            register7 <= 0;
        end
    end

    always @(OUT1ADDRESS,OUT2ADDRESS,CLK) begin
        case (OUT1ADDRESS)
            #2;
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
            #2;
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