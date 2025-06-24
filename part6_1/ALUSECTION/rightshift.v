//=================== Right Shift Operation Modes ===================
//      ROR (Rotate Right) - 111   (I7)  - SETPIN = 00
//      SRL (Shift Right Logical) - 101   - SETPIN = 10  
//      SRA (Shift Right Arithmetic) - 110 (I6) - SETPIN = 11

// Include component
`include "ALUSECTION/COMPENENT.v"

// Top-level Right Shift Module with timing delay
module RIGHTshift(DATA1,DATA2,OUTPUT,SETPIN);
    input [7:0]DATA1;      
    input [7:0]DATA2;      
    input [1:0]SETPIN;     // 2-bit mode control (00: ROR, 10: SRL, 11: SRA)
    output [7:0]OUTPUT;    

    wire [7:0]InternalOUTPUT;  // Internal wire for connection
    
    // Instantiate the right shift module
    RIGHTshiftMODULE Rmodule(DATA1,DATA2,InternalOUTPUT,SETPIN);
    
    // Add 2 time unit delay to final output
    assign #2 OUTPUT=InternalOUTPUT;
endmodule




// Core Right Shift Module implementing barrel shifter
// Supports rotate right (ROR), shift right logical (SRL), and shift right arithmetic (SRA)
module RIGHTshiftMODULE(DATA1,DATA2,OUTPUT,SETPIN);
    input [7:0] DATA1;      
    input [7:0] DATA2;      
    input [1:0] SETPIN;     // Mode selection: 00=ROR, 10=SRL, 11=SRA
    output [7:0] OUTPUT;    
    
    // Intermediate wires for 3-layer barrel shifter
    wire [7:0] s0, s1, s2;  // Results after each layer of shifting
    
    // Fill-in values for different shift operations at each layer
    wire F1;                // Fill value for layer 1 (shift by 1)
    wire F2, S2;           // Fill values for layer 2 (shift by 2)
    wire F3, S3, T3, U3;   // Fill values for layer 3 (shift by 4)

    // First Layer: Shift by 1 if DATA2[0] = 
    // Each bit gets value from itself (no shift) or from next higher bit (shift by 1)
    MULTIPLEXER mulr1(DATA1[7],F1,s0[7],DATA2[0]);        // Bit 7:from DATA1[7] or fill value F1
    MULTIPLEXER mulr2(DATA1[6],DATA1[7],s0[6],DATA2[0]);  // Bit 6:from DATA1[6] or DATA1[7]
    MULTIPLEXER mulr3(DATA1[5],DATA1[6],s0[5],DATA2[0]);  // Bit 5:from DATA1[5] or DATA1[6]
    MULTIPLEXER mulr4(DATA1[4],DATA1[5],s0[4],DATA2[0]);  // Bit 4:from DATA1[4] or DATA1[5]
    MULTIPLEXER mulr5(DATA1[3],DATA1[4],s0[3],DATA2[0]);  // Bit 3:from DATA1[3] or DATA1[4]
    MULTIPLEXER mulr6(DATA1[2],DATA1[3],s0[2],DATA2[0]);  // Bit 2:from DATA1[2] or DATA1[3]
    MULTIPLEXER mulr7(DATA1[1],DATA1[2],s0[1],DATA2[0]);  // Bit 1:from DATA1[1] or DATA1[2]
    MULTIPLEXER mulr8(DATA1[0],DATA1[1],s0[0],DATA2[0]);  // Bit 0:from DATA1[0] or DATA1[1]
    
    // Determine fill value F1 based on operation mode
    // ROR (00):Use DATA1[0] (bit rotated from LSB to MSB)
    // SRL (10):Use 1'b0 (logical shift fills with 0)
    // SRA (11):Use DATA1[7] (arithmetic shift fills with sign bit)
    MULTIPLEXER_3to1 mul3_1(DATA1[0],1'b0,DATA1[7],F1,SETPIN);


    // Second Layer: Shift by 2 if DATA2[1] = 1 
    // Each bit gets value from previous layer (no additional shift) or 2 positions higher
    MULTIPLEXER mulr9(s0[7],F2,s1[7],DATA2[1]);          // Bit 7:from s0[7] or fill F2
    MULTIPLEXER mulr10(s0[6],S2,s1[6],DATA2[1]);         // Bit 6:from s0[6] or fill S2
    MULTIPLEXER mulr11(s0[5],s0[7],s1[5],DATA2[1]);      // Bit 5:from s0[5] or s0[7]
    MULTIPLEXER mulr12(s0[4],s0[6],s1[4],DATA2[1]);      // Bit 4:from s0[4] or s0[6]
    MULTIPLEXER mulr13(s0[3],s0[5],s1[3],DATA2[1]);      // Bit 3:from s0[3] or s0[5]
    MULTIPLEXER mulr14(s0[2],s0[4],s1[2],DATA2[1]);      // Bit 2:from s0[2] or s0[4]
    MULTIPLEXER mulr15(s0[1],s0[3],s1[1],DATA2[1]);      // Bit 1:from s0[1] or s0[3]
    MULTIPLEXER mulr16(s0[0],s0[2],s1[0],DATA2[1]);      // Bit 0:from s0[0] or s0[2]

    // Determine fill values for positions requiring 2-bit fill
    // ROR:Use bits that would rotate around (s0[1], s0[0])
    // SRL:Use 0 for logical shift
    // SRA:Use sign bit (s0[7]) for arithmetic shift
    MULTIPLEXER_3to1 mul3_2(s0[1],1'b0,s0[7],F2,SETPIN);
    MULTIPLEXER_3to1 mul3_3(s0[0],1'b0,s0[7],S2,SETPIN);
    

    // Third Layer: Shift by 4 if DATA2[2] = 1
    // Each bit gets value from previous layer (no additional shift) or 4 positions higher
    MULTIPLEXER mulr17(s1[7],F3,s2[7],DATA2[2]);         // Bit 7:from s1[7] or fill F3
    MULTIPLEXER mulr18(s1[6],S3,s2[6],DATA2[2]);         // Bit 6:from s1[6] or fill S3
    MULTIPLEXER mulr19(s1[5],T3,s2[5],DATA2[2]);         // Bit 5:from s1[5] or fill T3
    MULTIPLEXER mulr20(s1[4],U3,s2[4],DATA2[2]);         // Bit 4:from s1[4] or fill U3
    MULTIPLEXER mulr21(s1[3],s1[7],s2[3],DATA2[2]);      // Bit 3:from s1[3] or s1[7]
    MULTIPLEXER mulr22(s1[2],s1[6],s2[2],DATA2[2]);      // Bit 2:from s1[2] or s1[6]
    MULTIPLEXER mulr23(s1[1],s1[5],s2[1],DATA2[2]);      // Bit 1:from s1[1] or s1[5]
    MULTIPLEXER mulr24(s1[0],s1[4],s2[0],DATA2[2]);      // Bit 0:from s1[0] or s1[4]

    // Determine fill values for positions requiring 4-bit fill
    // ROR:Use bits that would rotate around (s1[3:0])
    // SRL:Use 0 for logical shift  
    // SRA:Use sign bit (s1[7]) for arithmetic shift
    MULTIPLEXER_3to1 mul3_4(s1[3],1'b0,s1[7],F3,SETPIN);  
    MULTIPLEXER_3to1 mul3_5(s1[2],1'b0,s1[7],S3,SETPIN);  
    MULTIPLEXER_3to1 mul3_6(s1[1],1'b0,s1[7],T3,SETPIN); 
    MULTIPLEXER_3to1 mul3_7(s1[0],1'b0,s1[7],U3,SETPIN);  





    //---------------Final Output Stage: Handle Large Shifts------------------------
    // For shifts >= 8, the behavior depends on the operation:
    // - ROR:Should still rotate (not handled correctly here)
    // - SRL:Should output all zeros
    // - SRA:Should output all sign bits (DATA1[7])
    
    wire shift_ge_8;      // 1 if shift amount >= 8
    wire select_sign;     // 1 if we should fill with sign bit for large SRA shifts
    wire [7:0] final_mux_out; // Final output after handling large shifts
    
    // Check if shift amount >= 8 (any of bits 3-7 in DATA2 are set)
    or gate_or2(shift_ge_8,DATA2[3],DATA2[4],DATA2[5],DATA2[6],DATA2[7]);
    
    // Select sign fill only for SRA (SETPIN=11) with large shifts
    and gate_and1(select_sign,shift_ge_8,SETPIN[0],SETPIN[1]);
    
    // Final multiplexers: choose between barrel shifter result or sign-extended result
    // If select_sign=1 (SRA with large shift), fill all bits with DATA1[7]
    // Otherwise, use the barrel shifter result s2
    MULTIPLEXER final_mux0(s2[0],DATA1[7],final_mux_out[0],select_sign);
    MULTIPLEXER final_mux1(s2[1],DATA1[7],final_mux_out[1],select_sign);
    MULTIPLEXER final_mux2(s2[2],DATA1[7],final_mux_out[2],select_sign);
    MULTIPLEXER final_mux3(s2[3],DATA1[7],final_mux_out[3],select_sign);
    MULTIPLEXER final_mux4(s2[4],DATA1[7],final_mux_out[4],select_sign);
    MULTIPLEXER final_mux5(s2[5],DATA1[7],final_mux_out[5],select_sign);
    MULTIPLEXER final_mux6(s2[6],DATA1[7],final_mux_out[6],select_sign);
    MULTIPLEXER final_mux7(s2[7],DATA1[7],final_mux_out[7],select_sign);

    // Assign final output
    assign OUTPUT = final_mux_out;
endmodule




// module RIGHTshift_tb;

//     reg [7:0] DATA1;
//     reg [7:0] DATA2;
//     reg [1:0]SETPIN;
//     wire [7:0] OUTPUT;

//     // Instantiate the module under test
//     RIGHTshift uut (
//         .DATA1(DATA1),
//         .DATA2(DATA2),
//         .SETPIN(SETPIN),
//         .OUTPUT(OUTPUT)
//     );

//     initial begin
//         $display("Time\tSETPIN\tDATA1\tDATA2\tOUTPUT");
//         $monitor("%0t\t%b\t%b\t%d\t%b", $time, SETPIN, DATA1, DATA2, OUTPUT);

//         // Test 1: ROR by 0 (no shift)
//         SETPIN = 00;
//         DATA1 = 8'b10011001;
//         DATA2 = 8'b00000000;
//         #10;

//         // Test 2: ROR by 1
//         SETPIN = 00;
//         DATA1 = 8'b10011001;
//         DATA2 = 8'b00000001;
//         #10;

//         // Test 3: ROR by 3
//         SETPIN = 00;
//         DATA1 = 8'b11000011;
//         DATA2 = 8'b00000011;
//         #10;

//         // Test 4: SRA by 0 (no shift)
//         SETPIN = 11;
//         DATA1 = 8'b10011001;
//         DATA2 = 8'b00000000;
//         #10;

//         // Test 5: SRA by 1
//         SETPIN = 11;
//         DATA1 = 8'b10011001;
//         DATA2 = 8'b00000001;
//         #10;

//         // Test 6: SRA by 3
//         SETPIN = 11;
//         DATA1 = 8'b11100000;
//         DATA2 = 8'b00000011;
//         #10;

//         // Test 7: SRA by 7 (all bits should be sign-extended)
//         SETPIN = 11;
//         DATA1 = 8'b10000000;
//         DATA2 = 8'b00000111;
//         #10;

//         SETPIN = 11;
//         DATA1 = 8'b10000000;
//         DATA2 = 8'b01001000;
//         #10;

//         SETPIN = 00;
//         DATA1 = 8'b11110001;
//         DATA2 = 8'b00000010;
//         #10;

//         SETPIN = 01;
//         DATA1 = 8'b11110001;
//         DATA2 = 8'b00100011;
//         #10;


//         $finish;
//     end

// endmodule