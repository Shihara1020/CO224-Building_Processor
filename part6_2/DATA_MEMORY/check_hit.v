`timescale  1ns/100ps
module HITORNOT(VALID,CACHE_TAG,TARGET_TAG,HIT);
    input VALID;
    input[2:0] CACHE_TAG,TTAD;
    output HIT;
    
    wire tag_match_bit0, tag_match_bit1, tag_match_bit2;
    wire tag_match;

    xnor (tag_match_bit0,CACHE_TAG[0],TARGET_TAG[0]);
    xnor (tag_match_bit1,CACHE_TAG[1],TARGET_TAG[1]);
    xnor (tag_match_bit2,CACHE_TAG[2],TARGET_TAG[2]);

    and (tag_match, tag_match_bit0, tag_match_bit1, tag_match_bit2);


    and andGate(HIT,tag_match,VALID);


endmodule