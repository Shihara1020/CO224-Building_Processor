
//================Built Multiply Module================

// Half Adder Module
module HAIF_ADDER(A,B,S,C); 
    input A,B;        
    output S,C;      
    
    xor(S,A,B);     
    and(C,A,B);    
endmodule

// Full Adder Module
module FULL_ADDER(A,B,Cin,S,Cout);
    input A,B,Cin;      
    output S,Cout;       
     
    wire out1,C1,C2;    //Intermediate wires
    
    // First half adder: adds A and B
    HAIF_ADDER adder1(A,B,out1,C1);
    
    // Second half adder: adds result of first adder with carry input
    HAIF_ADDER adder2(out1,Cin,S,C2);
    
    // Final carry is OR of both carry outputs
    or(Cout,C1,C2);
endmodule

// 8-bit Array Multiplier Module
// Implements multiplication using partial products and carry-save addition
// Only keeps lower 8 bits of the 16-bit product result
module multiply(DATA1,DATA2,RESULT);
    input [7:0] DATA1,DATA2;   
    output [7:0] RESULT;        

    // Carry arrays for each row of addition
    wire [7:0] C0,C1,C2,C3,C4,C5,C6,C7;  // Carry signals for each row
    
    // Sum arrays for intermediate results
    wire [7:0] S0,S1,S2,S3,S4,S5,S6;      // Sum outputs from each row
    
    wire [7:0] OUTPUT;           // Final output wire
   
    // LSB of result: simple AND of LSBs (no addition needed)
    and(OUTPUT[0], DATA1[0], DATA2[0]);

    // First Row (DATA2[0] * DATA1[7:0])
    HAIF_ADDER HF0(DATA1[1]&DATA2[0],DATA1[0]&DATA2[1],OUTPUT[1],C0[0]);
    FULL_ADDER FA1(DATA1[2]&DATA2[0],DATA1[1]&DATA2[1],C0[0],S0[0],C0[1]);
    FULL_ADDER FA2(DATA1[3]&DATA2[0],DATA1[2]&DATA2[1],C0[1],S0[1],C0[2]);
    FULL_ADDER FA3(DATA1[4]&DATA2[0],DATA1[3]&DATA2[1],C0[2],S0[2],C0[3]);
    FULL_ADDER FA4(DATA1[5]&DATA2[0],DATA1[4]&DATA2[1],C0[3],S0[3],C0[4]);
    FULL_ADDER FA5(DATA1[6]&DATA2[0],DATA1[5]&DATA2[1],C0[4],S0[4],C0[5]);
    FULL_ADDER FA6(DATA1[7]&DATA2[0],DATA1[6]&DATA2[1],C0[5],S0[5],C0[6]);

    //Second Row (Add DATA2[2] partial products)
    //Add previous row sums with DATA1[i] & DATA2[2] partial products
    HAIF_ADDER HF2(S0[0],DATA1[0]&DATA2[2],OUTPUT[2],C1[0]);
    FULL_ADDER FA61(S0[1],DATA1[1]&DATA2[2],C1[0],S1[0],C1[1]);
    FULL_ADDER FA7(S0[2],DATA1[2]&DATA2[2],C1[1],S1[1],C1[2]);
    FULL_ADDER FA8(S0[3],DATA1[3]&DATA2[2],C1[2],S1[2],C1[3]);
    FULL_ADDER FA9(S0[4],DATA1[4]&DATA2[2],C1[3],S1[3],C1[4]);
    FULL_ADDER FA10(S0[5],DATA1[5]&DATA2[2],C1[4],S1[4],C1[5]);
    // Higher order terms truncated for 8-bit result

    //Third Row (Add DATA2[3] partial products)
    // Add previous row sums with DATA1[i] & DATA2[3] partial products
    HAIF_ADDER HF3(S1[0],DATA1[0]&DATA2[3],OUTPUT[3],C2[0]);
    FULL_ADDER FA11(S1[1],DATA1[1]&DATA2[3],C2[0],S2[0],C2[1]);
    FULL_ADDER FA12(S1[2],DATA1[2]&DATA2[3],C2[1],S2[1],C2[2]);
    FULL_ADDER FA13(S1[3],DATA1[3]&DATA2[3],C2[2],S2[2],C2[3]);
    FULL_ADDER FA14(S1[4],DATA1[4]&DATA2[3],C2[3],S2[3],C2[4]);

    //Fourth Row (Add DATA2[4] partial products)
    // Add previous row sums with DATA1[i] & DATA2[4] partial products
    HAIF_ADDER HF4(S2[0],DATA1[0]&DATA2[4],OUTPUT[4],C3[0]);
    FULL_ADDER FA15(S2[1],DATA1[1]&DATA2[4],C3[0],S3[0],C3[1]);
    FULL_ADDER FA16(S2[2],DATA1[2]&DATA2[4],C3[1],S3[1],C3[2]);
    FULL_ADDER FA17(S2[3],DATA1[3]&DATA2[4],C3[2],S3[2],C3[3]);

    //Fifth Row (Add DATA2[5] partial products)
    // Add previous row sums with DATA1[i] & DATA2[5] partial products
    HAIF_ADDER HF5(S3[0],DATA1[0]&DATA2[5],OUTPUT[5],C4[0]);
    FULL_ADDER FA18(S3[1],DATA1[1]&DATA2[5],C3[0],S4[0],C4[1]);
    FULL_ADDER FA19(S3[2],DATA1[2]&DATA2[5],C3[1],S4[1],C4[2]);

    //Sixth Row (Add DATA2[6] partial products)
    // Add previous row sums with DATA1[i] & DATA2[6] partial products
    HAIF_ADDER HF6(S4[0],DATA1[0]&DATA2[6],OUTPUT[6],C5[0]);
    FULL_ADDER FA20(S4[1],DATA1[1]&DATA2[6],C5[0],S5[0],C5[1]);

    //Seventh Row (Add DATA2[7] partial products)
    //Final row: add remaining partial products for MSB
    HAIF_ADDER HF7(S5[0],DATA1[0]&DATA2[7],OUTPUT[7],C6[0]);

    // Assign final result with 2 time unit delay
    assign #2 RESULT=OUTPUT;

endmodule




// module test_multiplier;
//     reg [7:0] DATA1, DATA2;
//     wire [7:0] OUTPUT;

//     // Instantiate your multiplier module
//     multiply uut (
//         .DATA1(DATA1),
//         .DATA2(DATA2),
//         .RESULT(OUTPUT)
//     );

//     initial begin
//         $display("DATA1\tDATA2\tExpected\tOUTPUT");

//         DATA1 = 8'd3; DATA2 = 8'd2; #10;
//         $display("%d\t%d\t%d\t\t%d", DATA1, DATA2, (DATA1 * DATA2) & 8'hFF, OUTPUT);

//         DATA1 = 8'd7; DATA2 = 8'd5; #10;
//         $display("%d\t%d\t%d\t\t%d", DATA1, DATA2, (DATA1 * DATA2) & 8'hFF, OUTPUT);

//         DATA1 = 8'd12; DATA2 = 8'd12; #10;
//         $display("%d\t%d\t%d\t\t%d", DATA1, DATA2, (DATA1 * DATA2) & 8'hFF, OUTPUT);

//         DATA1 = 8'd255; DATA2 = 8'd1; #10;
//         $display("%d\t%d\t%d\t\t%d", DATA1, DATA2, (DATA1 * DATA2) & 8'hFF, OUTPUT);

//         DATA1 = 8'd255; DATA2 = 8'd255; #10;
//         $display("%d\t%d\t%d\t\t%d", DATA1, DATA2, (DATA1 * DATA2) & 8'hFF, OUTPUT);

//         $finish;
//     end
// endmodule



