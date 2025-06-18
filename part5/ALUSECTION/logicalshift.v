// Include the right shift module 
`include "ALUSECTION/rightshift.v"

// Top-level Logical Shift Module
// Performs both left and right logical shifts based on DATA2[7] (MSB of shift amount)
// If DATA2[7] = 0: left shift, if DATA2[7] = 1: right shift
module Logicalshift(DATA1,DATA2,OUTPUT);
    input [7:0]DATA1;    
    input [7:0]DATA2;    
    output [7:0]OUTPUT;  

    wire [7:0] LOUTPUT,ROUTPUT;  
    
    // Instantiate left shift module
    LEFTshift left_gate(DATA1,DATA2,LOUTPUT);
    
    // Instantiate right shift module with logical shift mode (2'b01)
    RIGHTshiftMODULE right_gate(DATA1,DATA2,ROUTPUT,2'b01);
    
    // Select between left and right shift based on MSB of DATA2
    // If DATA2[7] = 0: select left shift, if DATA2[7] = 1: select right shift
    wire [7:0]s2;
    mux_unit2 MUX7_1(LOUTPUT,ROUTPUT,s2,DATA2[7]);

    // Check if shift amount >= 8 (bits 3-6 of DATA2)
    // If any of these bits are 1, the shift amount is >= 8
    wire shift_ge_8;
    or or_gate1(shift_ge_8,DATA2[3],DATA2[4],DATA2[5],DATA2[6]);

    // Final output stage: if shift >= 8, output all zeros
    wire [7:0]final_left_out;
    
    // If shift_ge_8 = 1, select 8'b0; if shift_ge_8 = 0, select s2
    // Using multiplexers for each bit
    MULTIPLEXER left_mux0(s2[0],1'b0,final_left_out[0],shift_ge_8);  // Bit 0
    MULTIPLEXER left_mux1(s2[1],1'b0,final_left_out[1],shift_ge_8);  // Bit 1
    MULTIPLEXER left_mux2(s2[2],1'b0,final_left_out[2],shift_ge_8);  // Bit 2
    MULTIPLEXER left_mux3(s2[3],1'b0,final_left_out[3],shift_ge_8);  // Bit 3
    MULTIPLEXER left_mux4(s2[4],1'b0,final_left_out[4],shift_ge_8);  // Bit 4
    MULTIPLEXER left_mux5(s2[5],1'b0,final_left_out[5],shift_ge_8);  // Bit 5
    MULTIPLEXER left_mux6(s2[6],1'b0,final_left_out[6],shift_ge_8);  // Bit 6
    MULTIPLEXER left_mux7(s2[7],1'b0,final_left_out[7],shift_ge_8);  // Bit 7

    // Assign final output with 2 time unit delay
    assign #2 OUTPUT=final_left_out;
endmodule

// Left Shift Module
// Implements barrel shifter using 3 layers of multiplexers
// Supports shift amounts from 0 to 7 positions
module LEFTshift(DATA1,DATA2,OUTPUT);
    input [7:0]DATA1;    
    input [7:0]DATA2;    
    output [7:0]OUTPUT; 

    // Intermediate wires for each layer of the barrel shifter
    wire [7:0] s0, s1, s2;  // s0: after 1st layer, s1: after 2nd layer, s2: final result
    
    // First layer: shift by 1 position if DATA2[0] = 1
    // Each bit position gets input from itself (no shift) or next higher bit (shift by 1)
    MULTIPLEXER mul1(DATA1[7],DATA1[6],s0[7],DATA2[0]);  // Bit 7:from bit 7 or 6
    MULTIPLEXER mul2(DATA1[6],DATA1[5],s0[6],DATA2[0]);  // Bit 6:from bit 6 or 5
    MULTIPLEXER mul3(DATA1[5],DATA1[4],s0[5],DATA2[0]);  // Bit 5:from bit 5 or 4
    MULTIPLEXER mul4(DATA1[4],DATA1[3],s0[4],DATA2[0]);  // Bit 4:from bit 4 or 3
    MULTIPLEXER mul5(DATA1[3],DATA1[2],s0[3],DATA2[0]);  // Bit 3:from bit 3 or 2
    MULTIPLEXER mul6(DATA1[2],DATA1[1],s0[2],DATA2[0]);  // Bit 2:from bit 2 or 1
    MULTIPLEXER mul7(DATA1[1],DATA1[0],s0[1],DATA2[0]);  // Bit 1:from bit 1 or 0
    MULTIPLEXER mul8(DATA1[0],1'b0,s0[0],DATA2[0]);      // Bit 0:from bit 0 or 0 (fill with 0)

    // Second layer: shift by 2 positions if DATA2[1] = 1
    // Each bit position gets input from s0 (no additional shift) or 2 positions higher
    MULTIPLEXER mul9(s0[7],s0[5],s1[7],DATA2[1]);        // Bit 7:from s0[7] or s0[5]
    MULTIPLEXER mul10(s0[6],s0[4],s1[6],DATA2[1]);       // Bit 6:from s0[6] or s0[4]
    MULTIPLEXER mul11(s0[5],s0[3],s1[5],DATA2[1]);       // Bit 5:from s0[5] or s0[3]
    MULTIPLEXER mul12(s0[4],s0[2],s1[4],DATA2[1]);       // Bit 4:from s0[4] or s0[2]
    MULTIPLEXER mul13(s0[3],s0[1],s1[3],DATA2[1]);       // Bit 3:from s0[3] or s0[1]
    MULTIPLEXER mul14(s0[2],s0[0],s1[2],DATA2[1]);       // Bit 2:from s0[2] or s0[0]
    MULTIPLEXER mul15(s0[1],1'b0,s1[1],DATA2[1]);        // Bit 1:from s0[1] or 0
    MULTIPLEXER mul16(s0[0],1'b0,s1[0],DATA2[1]);        // Bit 0:from s0[0] or 0

    // Third layer: shift by 4 positions if DATA2[2] = 1
    // Each bit position gets input from s1 (no additional shift) or 4 positions higher
    MULTIPLEXER mul17(s1[7],s1[3],s2[7],DATA2[2]);       // Bit 7:from s1[7] or s1[3]
    MULTIPLEXER mul18(s1[6],s1[2],s2[6],DATA2[2]);       // Bit 6:from s1[6] or s1[2]
    MULTIPLEXER mul19(s1[5],s1[1],s2[5],DATA2[2]);       // Bit 5:from s1[5] or s1[1]
    MULTIPLEXER mul20(s1[4],s1[0],s2[4],DATA2[2]);       // Bit 4:from s1[4] or s1[0]
    MULTIPLEXER mul21(s1[3],1'b0,s2[3],DATA2[2]);        // Bit 3:from s1[3] or 0
    MULTIPLEXER mul22(s1[2],1'b0,s2[2],DATA2[2]);        // Bit 2:from s1[2] or 0
    MULTIPLEXER mul23(s1[1],1'b0,s2[1],DATA2[2]);        // Bit 1:from s1[1] or 0
    MULTIPLEXER mul24(s1[0],1'b0,s2[0],DATA2[2]);        // Bit 0:from s1[0] or 0

    // Final output assignment
    assign OUTPUT = s2;
endmodule


// module LOGICALshift_tb;

//     reg [7:0] DATA1;
//     reg [7:0] DATA2;
//     wire [7:0] OUTPUT;

//     // Instantiate the module under test
//     Logicalshift uut (
//         .DATA1(DATA1),
//         .DATA2(DATA2),
//         .OUTPUT(OUTPUT)
//     );

//     initial begin
//         $display("Time\tDATA1\tDATA2\tOUTPUT");
//         $monitor("%0t\t%b\t%d\t%b", $time, DATA1, DATA2, OUTPUT);

//         // Test case 1: Shift 0 positions
//         DATA1 = 8'b10101010;
//         DATA2 = 8'b10000000;
//         #10;

//         // Test case 2: Shift 1 position
//         DATA1 = 8'b10101010;
//         DATA2 = 8'b10000001;
//         #10;

//         // Test case 3: Shift 2 positions
//         DATA1 = 8'b11110000;
//         DATA2 = 8'b10000010;
//         #10;

//         // Test case 4: Shift 3 positions
//         DATA1 = 8'b00001111;
//         DATA2 = 8'b10000011;
//         #10;

//         // Test case 5: Shift 4 positions
//         DATA1 = 8'b11001100;
//         DATA2 = 8'b10000100;
//         #10;

//         // Test case 6: Shift 5 positions
//         DATA1 = 8'b00010001;
//         DATA2 = 8'b10000101;
//         #10;

//         // Test case 7: Shift 6 positions
//         DATA1 = 8'b10000001;
//         DATA2 = 8'b10000110;
//         #10;

//         // Test case 8: Shift 7 positions
//         DATA1 = 8'b11111111;
//         DATA2 = 8'b10111111;
//         #10;

//         // End of test
//         $finish;
//     end

// endmodule











// module LEFTshift_tb;

//     reg [7:0] DATA1;
//     reg [7:0] DATA2;
//     wire [7:0] OUTPUT;

//     // Instantiate the module under test
//     LEFTshift uut (
//         .DATA1(DATA1),
//         .DATA2(DATA2),
//         .OUTPUT(OUTPUT)
//     );

//     initial begin
//         $display("Time\tDATA1\tDATA2\tOUTPUT");
//         $monitor("%0t\t%b\t%d\t%b", $time, DATA1, DATA2, OUTPUT);

//         // Test case 1: Shift 0 positions
//         DATA1 = 8'b10101010;
//         DATA2 = 8'b00000000;
//         #10;

//         // Test case 2: Shift 1 position
//         DATA1 = 8'b10101010;
//         DATA2 = 8'b00000001;
//         #10;

//         // Test case 3: Shift 2 positions
//         DATA1 = 8'b11110000;
//         DATA2 = 8'b00000010;
//         #10;

//         // Test case 4: Shift 3 positions
//         DATA1 = 8'b00001111;
//         DATA2 = 8'b00000011;
//         #10;

//         // Test case 5: Shift 4 positions
//         DATA1 = 8'b11001100;
//         DATA2 = 8'b00000100;
//         #10;

//         // Test case 6: Shift 5 positions
//         DATA1 = 8'b00010001;
//         DATA2 = 8'b00000101;
//         #10;

//         // Test case 7: Shift 6 positions
//         DATA1 = 8'b10000001;
//         DATA2 = 8'b00000110;
//         #10;

//         // Test case 8: Shift 7 positions
//         DATA1 = 8'b11111111;
//         DATA2 = 8'b00111111;
//         #10;

//         // End of test
//         $finish;
//     end

// endmodule



