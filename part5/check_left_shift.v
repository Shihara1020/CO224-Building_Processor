//left shift function for alu
//delay of 2units time
module MULTIPLEXER(A0,A1,B,select);
    input A0,A1,select;
    output B;

    assign B=(select)?A1:A0;

endmodule


//      SRA     - 110   (I6) - SETPIN-1
//      ROR     - 111   (I7)  -SETPIN-0

module RIGHTshift(DATA1,DATA2,OUTPUT,SETPIN);
    input[7:0]DATA1;
    input[2:0]DATA2;
    input SETPIN;
    output reg[7:0]OUTPUT;
    
    wire [7:0]s0,s1,s2;


    wire F1;
    wire F2,S2;
    wire F3,S3,T3;

    //first layer
    MULTIPLEXER mulr1(DATA1[7],F1,s0[7],DATA2[0]);
    MULTIPLEXER mulr2(DATA1[6],DATA1[7],s0[6],DATA2[0]);
    MULTIPLEXER mulr3(DATA1[5],DATA1[6],s0[5],DATA2[0]);
    MULTIPLEXER mulr4(DATA1[4],DATA1[5],s0[4],DATA2[0]);
    MULTIPLEXER mulr5(DATA1[3],DATA1[4],s0[3],DATA2[0]);
    MULTIPLEXER mulr6(DATA1[2],DATA1[3],s0[2],DATA2[0]);
    MULTIPLEXER mulr7(DATA1[1],DATA1[2],s0[1],DATA2[0]);
    MULTIPLEXER mulr8(DATA1[0],DATA1[1],s0[0],DATA2[0]);
    
    MULTIPLEXER mul3_1(DATA1[0],DATA1[7],F1,SETPIN);


    //Second layer
    MULTIPLEXER mulr9(s0[7],F2,s1[7],DATA2[1]);
    MULTIPLEXER mulr10(s0[6],S2,s1[6],DATA2[1]);
    MULTIPLEXER mulr11(s0[5],s0[7],s1[5],DATA2[1]);
    MULTIPLEXER mulr12(s0[4],s0[6],s1[4],DATA2[1]);
    MULTIPLEXER mulr13(s0[3],s0[5],s1[3],DATA2[1]);
    MULTIPLEXER mulr14(s0[2],s0[4],s1[2],DATA2[1]);
    MULTIPLEXER mulr15(s0[1],s0[3],s1[1],DATA2[1]);
    MULTIPLEXER mulr16(s0[0],s0[2],s1[0],DATA2[1]);

    MULTIPLEXER mul3_2(s0[0],s0[7],F2,SETPIN);  //S0[0]->rotate , s0[7]-sign extend
    MULTIPLEXER mul3_3(s0[2],s0[7],S2,SETPIN);
    

    //Third layer
    MULTIPLEXER mulr17(s1[7],F3,s2[7],DATA2[2]);
    MULTIPLEXER mulr18(s1[6],S3,s2[6],DATA2[2]);
    MULTIPLEXER mulr19(s1[5],T3,s2[5],DATA2[2]);
    MULTIPLEXER mulr20(s1[4],s0[7],s2[4],DATA2[2]);
    MULTIPLEXER mulr21(s1[3],s0[6],s2[3],DATA2[2]);
    MULTIPLEXER mulr22(s1[2],s0[5],s2[2],DATA2[2]);
    MULTIPLEXER mulr23(s1[1],s0[4],s2[1],DATA2[2]);
    MULTIPLEXER mulr24(s1[0],s0[3],s2[0],DATA2[2]);

    MULTIPLEXER mul3_4(s1[0],s1[7],F3,SETPIN);
    MULTIPLEXER mul3_5(s1[2],s1[7],S3,SETPIN);
    MULTIPLEXER mul3_6(s1[3],s1[7],T3,SETPIN);

    //Setting final output after 2 time unit delay
	always @ (DATA1, DATA2, s2)
	begin
		# 2 OUTPUT=s2;
    end

endmodule


module RIGHTshift_tb;

    reg [7:0] DATA1;
    reg [2:0] DATA2;
    reg SETPIN;
    wire [7:0] OUTPUT;

    // Instantiate the module under test
    RIGHTshift uut (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .SETPIN(SETPIN),
        .OUTPUT(OUTPUT)
    );

    initial begin
        $display("Time\tSETPIN\tDATA1\tDATA2\tOUTPUT");
        $monitor("%0t\t%b\t%b\t%d\t%b", $time, SETPIN, DATA1, DATA2, OUTPUT);

        // Test 1: ROR by 0 (no shift)
        SETPIN = 0;
        DATA1 = 8'b10011001;
        DATA2 = 3'b000;
        #10;

        // Test 2: ROR by 1
        SETPIN = 0;
        DATA1 = 8'b10011001;
        DATA2 = 3'b001;
        #10;

        // Test 3: ROR by 3
        SETPIN = 0;
        DATA1 = 8'b11000011;
        DATA2 = 3'b011;
        #10;

        // Test 4: SRA by 0 (no shift)
        SETPIN = 1;
        DATA1 = 8'b10011001;
        DATA2 = 3'b000;
        #10;

        // Test 5: SRA by 1
        SETPIN = 1;
        DATA1 = 8'b10011001;
        DATA2 = 3'b001;
        #10;

        // Test 6: SRA by 3
        SETPIN = 1;
        DATA1 = 8'b11100000;
        DATA2 = 3'b011;
        #10;

        // Test 7: SRA by 7 (all bits should be sign-extended)
        SETPIN = 1;
        DATA1 = 8'b10000000;
        DATA2 = 3'b111;
        #10;

        $finish;
    end

endmodule
