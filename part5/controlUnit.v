module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX,BRANCH);
input [7:0] OPCODE;
output reg [2:0] ALUOP;
output reg ALUSRC;
output reg WRITEENABLE;
output reg NEMUX;  //the enter the negative number
output reg [1:0]BRANCH;

/*       OP-CODE

	add   = "00000000";  -done
    sub   = "00000001";  -done 
	and   = "00000010";  -done
	or 	  = "00000011";  -done
	mov   = "00000100";  -done
	loadi = "00000101";  -done
    j	  = "00000110";  -done
	beq	  = "00000111";  -done

    bne   = "00001000";  -done
    mult  = "00001001";  -done
    sl   = "00001010";  -done (logical left shift and right shift)
    srl   = "00001011";  -no need 
    sra   = "00001100";  -done
    ror   = "00001101";  -done
*/


/*

        BRANCH
    00 -Normal flow
    01-j
    10-beq
    11-bnq


*/
always @(OPCODE) begin
    #1
    if (OPCODE==8'b00000000) begin   //add  -done
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=2'b00;

    end
    else if (OPCODE==8'b00000001) begin  //sub   -done
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=2'b00;

        
    end
    else if (OPCODE==8'b00000010) begin  //and   -done
        WRITEENABLE=1'b1;
        ALUOP=3'b010;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=2'b00;

    end
    else if (OPCODE==8'b00000011) begin //or   -done
        WRITEENABLE=1'b1;
        ALUOP=3'b011;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end
    else if (OPCODE==8'b00000100) begin //mov   -done
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end
    else if (OPCODE==8'b00000101) begin //loadi   -done
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end   
    else if (OPCODE==8'b00000110) begin //J -done
        WRITEENABLE=1'b0;
        ALUOP=3'b000;   //dont use
        ALUSRC=1'b0;    //dont use
        NEMUX=1'b0;     //dont use
        BRANCH=2'b01;

    end
    else if (OPCODE==8'b00000111) begin //beq  -done
        WRITEENABLE=1'b0;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=2'b10;

        
    end
    //add new featutes
    else if (OPCODE==8'b00001000) begin //bne  -done
        WRITEENABLE=1'b0;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=2'b11;

    end

    
    else if (OPCODE==8'b00001001) begin //mult  -done
        WRITEENABLE=1'b1;
        ALUOP=3'b100;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end

    else if (OPCODE==8'b00001010) begin //sl  -done
        WRITEENABLE=1'b1;
        ALUOP=3'b101;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end

    else if (OPCODE==8'b00001100) begin //sra -done
        WRITEENABLE=1'b1;
        ALUOP=3'b110;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=2'b00;

        
    end
    else if (OPCODE==8'b00001101) begin //ror -done
        WRITEENABLE=1'b1;
        ALUOP=3'b111;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=2'b00;

    end
end
endmodule