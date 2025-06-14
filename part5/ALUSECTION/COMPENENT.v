// 1-bit Multiplexer using gates
// Logic: B = (select' AND A0) OR (select AND A1)
module MULTIPLEXER(A0, A1, B, select);
    input A0, A1, select;
    output B;
    
    wire select_n;  // inverted select
    wire and1_out;  // select' AND A0
    wire and2_out;  // select AND A1
    
    // Invert select signal
    not (select_n, select);
    
    // AND gates
    and (and1_out, select_n, A0);  // select' AND A0
    and (and2_out, select, A1);    // select AND A1
    
    // OR gate for final output
    or (B, and1_out, and2_out);
endmodule

module mux_unit2(DATA1, DATA2, OUTPUT, select);
    input signed [7:0] DATA1;
    input signed [7:0] DATA2;
    input select;
    output signed [7:0] OUTPUT;
    
    // Use the 1-bit multiplexer for each bit
    MULTIPLEXER mux0(DATA1[0], DATA2[0], OUTPUT[0], select);
    MULTIPLEXER mux1(DATA1[1], DATA2[1], OUTPUT[1], select);
    MULTIPLEXER mux2(DATA1[2], DATA2[2], OUTPUT[2], select);
    MULTIPLEXER mux3(DATA1[3], DATA2[3], OUTPUT[3], select);
    MULTIPLEXER mux4(DATA1[4], DATA2[4], OUTPUT[4], select);
    MULTIPLEXER mux5(DATA1[5], DATA2[5], OUTPUT[5], select);
    MULTIPLEXER mux6(DATA1[6], DATA2[6], OUTPUT[6], select);
    MULTIPLEXER mux7(DATA1[7], DATA2[7], OUTPUT[7], select);
endmodule


module MULTIPLEXER_3to1(A0, A1, A2,Y,Select);
    input A0, A1, A2;     // Three data inputs
    input [1:0]Select;         // Two select lines
    output Y;             // Output
    
    wire S0_bar, S1_bar;  // Inverted select signals
    wire m0, m1, m2;      // Intermediate terms
    
    // Generate inverted select signals
    not(S0_bar, Select[0]);
    not(S1_bar, Select[1]);
    
    // Generate product terms for each input
    // m0 = A0 · S1' · S0'  (Select 00 - Choose A0)
    and(m0, A0, S1_bar, S0_bar);
    
    // m1 = A1 · S1' · S0   (Select 01 - Choose A1)  
    and(m1, A1, S1_bar, Select[0]);
    
    // m2 = A2 · S1 · S0   (Select 11 - Choose A2)
    and(m2, A2, Select[1], Select[0]);
    
    // Final output: Y = m0 + m1 + m2
    or(Y, m0, m1, m2);
    
endmodule