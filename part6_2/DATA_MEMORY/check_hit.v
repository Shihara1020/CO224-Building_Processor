module HITORNOT(CVALID,CTAG,TTAG,HIT);
    input CVALID;
    input[2:0] CTAG,TTAD;
    output HIT;
    
    wire tag_match_bit0, tag_match_bit1, tag_match_bit2;
    wire tag_match;

    xnor (tag_match_bit0,CTAG[0],TTAG[0]);
    xnor (tag_match_bit1,CTAG[1],TTAG[1]);
    xnor (tag_match_bit2,CTAG[2],TTAG[2]);

    and (tag_match, tag_match_bit0, tag_match_bit1, tag_match_bit2);


    and andGate(HIT,tag_match,CVALID);


endmodule