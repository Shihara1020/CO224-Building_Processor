// 1-bit Multiplexer using gates
// Logic: B = (select' AND A0) OR (select AND A1)
// When select = 0, output A0; when select = 1, output A1
module MULTIPLEXER(A0, A1, B, select);
    input A0, A1, select;    // Two data inputs and one select line
    output B;                // Single bit output
    
    wire select_n;  // inverted select signal
    wire and1_out;  // select' AND A0 - output when select=0
    wire and2_out;  // select AND A1 - output when select=1
    
    // Invert select signal to get select'
    not (select_n, select);
    
    // AND gates to implement multiplexer logic
    and (and1_out, select_n, A0);  // select' AND A0 - passes A0 when select=0
    and (and2_out, select, A1);    // select AND A1 - passes A1 when select=1
    
    // OR gate for final output - combines the two paths
    or (B, and1_out, and2_out);
endmodule

// 8-bit Multiplexer using 1-bit multiplexers
// Selects between two 8-bit signed data inputs
module mux_unit2(DATA1, DATA2, OUTPUT, select);
    input signed [7:0] DATA1;    // First 8-bit signed data input
    input signed [7:0] DATA2;    // Second 8-bit signed data input
    input select;                // Select line: 0 for DATA1, 1 for DATA2
    output signed [7:0] OUTPUT;  // 8-bit signed output
    
    // Use the 1-bit multiplexer for each bit position
    // This creates a bit-parallel multiplexer
    MULTIPLEXER mux0(DATA1[0], DATA2[0], OUTPUT[0], select);  // LSB (bit 0)
    MULTIPLEXER mux1(DATA1[1], DATA2[1], OUTPUT[1], select);  // bit 1
    MULTIPLEXER mux2(DATA1[2], DATA2[2], OUTPUT[2], select);  // bit 2
    MULTIPLEXER mux3(DATA1[3], DATA2[3], OUTPUT[3], select);  // bit 3
    MULTIPLEXER mux4(DATA1[4], DATA2[4], OUTPUT[4], select);  // bit 4
    MULTIPLEXER mux5(DATA1[5], DATA2[5], OUTPUT[5], select);  // bit 5
    MULTIPLEXER mux6(DATA1[6], DATA2[6], OUTPUT[6], select);  // bit 6
    MULTIPLEXER mux7(DATA1[7], DATA2[7], OUTPUT[7], select);  // MSB (bit 7)
endmodule

// 3-to-1 Multiplexer using gates
// Selects one of three inputs based on 2-bit select signal
// Select values: 00->A0, 01->A1, 11->A2 (10 is unused)
module MULTIPLEXER_3to1(A0, A1, A2, Y, Select);
    input A0, A1, A2;        // Three data inputs
    input [1:0] Select;      // Two select lines for 3-input selection
    output Y;                // Single bit output
    
    wire S0_bar, S1_bar;     // Inverted select signals
    wire m0, m1, m2;         // Intermediate product terms
    
    // Generate inverted select signals
    not(S0_bar, Select[0]);  // Invert S0
    not(S1_bar, Select[1]);  // Invert S1
    
    // Generate product terms for each input using AND gates
    // m0 = A0 · S1' · S0'  (Select 00 - Choose A0)
    and(m0, A0, S1_bar, S0_bar);
    
    // m1 = A1 · S1' · S0   (Select 01 - Choose A1)
    and(m1, A1, S1_bar, Select[0]);
    
    // m2 = A2 · S1 · S0    (Select 11 - Choose A2)
    // Note: Select = 10 is not used in this implementation
    and(m2, A2, Select[1], Select[0]);
    
    // Final output: Y = m0 + m1 + m2 (OR of all product terms)
    or(Y, m0, m1, m2);
endmodule