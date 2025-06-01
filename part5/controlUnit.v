module control_unit(OPCODE,WRITEENABLE,ALUSRC,ALUOP,NEMUX,BRANCH,JUMP,BNE);
input [7:0] OPCODE;
output reg [2:0] ALUOP;
output reg ALUSRC;
output reg WRITEENABLE;
output reg NEMUX;  //the enter the negative number
output reg BRANCH;
output reg JUMP;
output reg BNE;


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
    sll   = "00001010";  -done
    srl   = "00001011";
    sra   = "00001100";
    ror   = "00001101";
*/

always @(OPCODE) begin
    #1
    if (OPCODE==8'b00000000) begin   //add
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
    end
    else if (OPCODE==8'b00000001) begin  //sub
        WRITEENABLE=1'b1;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end
    else if (OPCODE==8'b00000010) begin  //and 
        WRITEENABLE=1'b1;
        ALUOP=3'b010;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
    end
    else if (OPCODE==8'b00000011) begin //or
        WRITEENABLE=1'b1;
        ALUOP=3'b011;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end
    else if (OPCODE==8'b00000100) begin //mov
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end
    else if (OPCODE==8'b00000101) begin //loadi
        WRITEENABLE=1'b1;
        ALUOP=3'b000;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end   
    else if (OPCODE==8'b00000110) begin //J
        WRITEENABLE=1'b0;
        ALUOP=3'b000;   //dont use
        ALUSRC=1'b0;    //dont use
        NEMUX=1'b0;     //dont use
        BRANCH=1'b0;
        JUMP=1'b1;
        BNE=1'b0;
    end
    else if (OPCODE==8'b00000111) begin //beq
        WRITEENABLE=1'b0;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=1'b1;
        JUMP=1'b0;
        BNE=1'b0;
        
    end

    else if (OPCODE==8'b00001000) begin //bne
        WRITEENABLE=1'b0;
        ALUOP=3'b001;
        ALUSRC=1'b1;
        NEMUX=1'b1;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b1;
    end

    //add new featutes
    else if (OPCODE==8'b00001001) begin //mult
        WRITEENABLE=1'b1;
        ALUOP=3'b100;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end

    else if (OPCODE==8'b00001010) begin //sll
        WRITEENABLE=1'b0;
        ALUOP=3'b101;
        ALUSRC=1'b1;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end

    else if (OPCODE==8'b00001110) begin //srl
        WRITEENABLE=1'b1;
        ALUOP=3'b111;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
    end
    else if (OPCODE==8'b00001111) begin //sra
        WRITEENABLE=1'b1;
        ALUOP=3'b111;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
        
    end
    else if (OPCODE==8'b00010000) begin //ror
        WRITEENABLE=1'b1;
        ALUOP=3'b111;
        ALUSRC=1'b0;
        NEMUX=1'b0;
        BRANCH=1'b0;
        JUMP=1'b0;
        BNE=1'b0;
    end
end
endmodule