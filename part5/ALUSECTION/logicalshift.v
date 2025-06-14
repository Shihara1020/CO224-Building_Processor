`include "ALUSECTION/rightshift.v"

module Logicalshift(DATA1,DATA2,OUTPUT);
    input[7:0]DATA1;
    input[7:0]DATA2;
    output[7:0]OUTPUT;

    wire [7:0]LOUTPUT,ROUTPUT;
    LEFTshift left_gate(DATA1,DATA2,LOUTPUT);
    RIGHTshiftMODULE right_gate(DATA1,DATA2,ROUTPUT,2'b01);
    
    //select Most significant bit is 1 then right shift and 0 then left shift
    wire [7:0]s2;
    mux_unit2 MUX7_1(LOUTPUT,ROUTPUT,s2,DATA2[7]);

    wire  shift_ge_8;
    or or_gate1(shift_ge_8,DATA2[3],DATA2[4],DATA2[5],DATA2[6]);

    wire [7:0] final_left_out;
    
    // If shift_ge_8 = 1, select 8'b0; if shift_ge_8 = 0, select s2
    MULTIPLEXER left_mux0(s2[0], 1'b0, final_left_out[0], shift_ge_8);
    MULTIPLEXER left_mux1(s2[1], 1'b0, final_left_out[1], shift_ge_8);
    MULTIPLEXER left_mux2(s2[2], 1'b0, final_left_out[2], shift_ge_8);
    MULTIPLEXER left_mux3(s2[3], 1'b0, final_left_out[3], shift_ge_8);
    MULTIPLEXER left_mux4(s2[4], 1'b0, final_left_out[4], shift_ge_8);
    MULTIPLEXER left_mux5(s2[5], 1'b0, final_left_out[5], shift_ge_8);
    MULTIPLEXER left_mux6(s2[6], 1'b0, final_left_out[6], shift_ge_8);
    MULTIPLEXER left_mux7(s2[7], 1'b0, final_left_out[7], shift_ge_8);

    assign #2 OUTPUT=final_left_out;



endmodule

module LEFTshift(DATA1,DATA2,OUTPUT);
    input[7:0]DATA1;
    input[7:0]DATA2;
    output[7:0]OUTPUT;

         
    wire [7:0]s0,s1,s2;
    //first layer
    MULTIPLEXER mul1(DATA1[7],DATA1[6],s0[7],DATA2[0]);
    MULTIPLEXER mul2(DATA1[6],DATA1[5],s0[6],DATA2[0]);
    MULTIPLEXER mul3(DATA1[5],DATA1[4],s0[5],DATA2[0]);
    MULTIPLEXER mul4(DATA1[4],DATA1[3],s0[4],DATA2[0]);
    MULTIPLEXER mul5(DATA1[3],DATA1[2],s0[3],DATA2[0]);
    MULTIPLEXER mul6(DATA1[2],DATA1[1],s0[2],DATA2[0]);
    MULTIPLEXER mul7(DATA1[1],DATA1[0],s0[1],DATA2[0]);
    MULTIPLEXER mul8(DATA1[0],1'b0,s0[0],DATA2[0]);


    //Second layer
    MULTIPLEXER mul9(s0[7],s0[5],s1[7],DATA2[1]);
    MULTIPLEXER mul10(s0[6],s0[4],s1[6],DATA2[1]);
    MULTIPLEXER mul11(s0[5],s0[3],s1[5],DATA2[1]);
    MULTIPLEXER mul12(s0[4],s0[2],s1[4],DATA2[1]);
    MULTIPLEXER mul13(s0[3],s0[1],s1[3],DATA2[1]);
    MULTIPLEXER mul14(s0[2],s0[0],s1[2],DATA2[1]);
    MULTIPLEXER mul15(s0[1],1'b0,s1[1],DATA2[1]);
    MULTIPLEXER mul16(s0[0],1'b0,s1[0],DATA2[1]);
    

    //Third layer
    MULTIPLEXER mul17(s1[7],s1[3],s2[7],DATA2[2]);
    MULTIPLEXER mul18(s1[6],s1[2],s2[6],DATA2[2]);
    MULTIPLEXER mul19(s1[5],s1[1],s2[5],DATA2[2]);
    MULTIPLEXER mul20(s1[4],s1[0],s2[4],DATA2[2]);
    MULTIPLEXER mul21(s1[3],1'b0,s2[3],DATA2[2]);
    MULTIPLEXER mul22(s1[2],1'b0,s2[2],DATA2[2]);
    MULTIPLEXER mul23(s1[1],1'b0,s2[1],DATA2[2]);
    MULTIPLEXER mul24(s1[0],1'b0,s2[0],DATA2[2]);

    assign OUTPUT=s2;
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



