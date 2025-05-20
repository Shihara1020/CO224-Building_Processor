module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX);
input [7:0] OPCODE;
output reg [2:0] ALUOP;
output reg ALUSRC;
output reg WRITEENABLE;
output NEMUX;  //the enter the negative number

/*       OP-CODE

	add   = "00000000";
    sub   = "00000001";
	and   = "00000010";
	or 	  = "00000011";
	mov   = "00000100";
	loadi = "00000101";
*/

always @(*) begin
    if (OPCODE==8'b00000000) begin   //add
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b0;
    end
    else if (OPCODE==8'b00000001) begin  //sub
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        
    end
    else if (OPCODE==8'b00000010) begin  //and 
        WRITEENABLE=1'b1;
        ALUOP=3'b010;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        
    end
    else if (OPCODE==8'b00000011) begin //or
        WRITEENABLE=1'b1;
        ALUOP=3'b011;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        
    end
    else if (OPCODE==8'b00000100) begin //mov
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        
    end
    else if (OPCODE==8'b00000101) begin //loadi
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        
    end    
end
endmodule