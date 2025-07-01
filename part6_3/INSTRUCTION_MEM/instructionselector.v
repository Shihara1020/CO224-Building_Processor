`timescale  1ns/100ps
module INSTSELECTOR(word1,word2,word3,word4,select,resultdata);
    input [31:0]word1,word2,word3,word4;
    input [1:0]select;
    output reg [31:0]resultdata;

    always @(word1,word2,word3,word4,select) begin
        case(select)
            2'b00: #1 resultdata=word1;
            2'b01: #1 resultdata=word2;
            2'b10: #1 resultdata=word3;
            2'b11: #1 resultdata=word4; 
        endcase
    end

endmodule