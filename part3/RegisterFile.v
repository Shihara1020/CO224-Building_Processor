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
