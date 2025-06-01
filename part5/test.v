`timescale 1ns/1ps

module MULTIPLEXER (
    input  wire A0,
    input  wire A1,
    input  wire select,
    output wire B
);
    assign B = (select) ? A1 : A0;
endmodule


module LEFTshift (
    input  wire [7:0] DATA1,
    input  wire [2:0] DATA2,
    output wire [7:0] OUTPUT
);
    wire [7:0] s0, s1, s2;

    // First layer: shift by 1
    genvar i;
    generate
        for (i = 0; i < 7; i = i + 1) begin : first_layer
            MULTIPLEXER mux1 (
                .A0(DATA1[i]),
                .A1(DATA1[i+1]),
                .select(DATA2[0]),
                .B(s0[i])
            );
        end
        MULTIPLEXER mux1_last (
            .A0(DATA1[7]),
            .A1(1'b0),
            .select(DATA2[0]),
            .B(s0[7])
        );
    endgenerate

    // Second layer: shift by 2
    generate
        for (i = 0; i < 6; i = i + 1) begin : second_layer
            MULTIPLEXER mux2 (
                .A0(s0[i]),
                .A1(s0[i+2]),
                .select(DATA2[1]),
                .B(s1[i])
            );
        end
        MULTIPLEXER mux2_6 (
            .A0(s0[6]),
            .A1(1'b0),
            .select(DATA2[1]),
            .B(s1[6])
        );
        MULTIPLEXER mux2_7 (
            .A0(s0[7]),
            .A1(1'b0),
            .select(DATA2[1]),
            .B(s1[7])
        );
    endgenerate

    // Third layer: shift by 4
    generate
        for (i = 0; i < 4; i = i + 1) begin : third_layer
            MULTIPLEXER mux3 (
                .A0(s1[i]),
                .A1(s1[i+4]),
                .select(DATA2[2]),
                .B(s2[i])
            );
        end
        for (i = 4; i < 8; i = i + 1) begin : third_layer_zero
            MULTIPLEXER mux3_zero (
                .A0(s1[i]),
                .A1(1'b0),
                .select(DATA2[2]),
                .B(s2[i])
            );
        end
    endgenerate

    assign #2 OUTPUT = s2;
endmodule


module RIGHTshift (
    input  wire [7:0] DATA1,
    input  wire [2:0] DATA2,
    input  wire       SETPIN, // 1 for arithmetic shift, 0 for rotate
    output wire [7:0] OUTPUT
);
    wire [7:0] s0, s1, s2;
    wire [7:0] fill;

    // Determine fill bits based on SETPIN
    assign fill = (SETPIN) ? {8{DATA1[7]}} : DATA1;

    // First layer: shift by 1
    genvar i;
    generate
        for (i = 7; i > 0; i = i - 1) begin : first_layer
            MULTIPLEXER mux1 (
                .A0(DATA1[i]),
                .A1(DATA1[i-1]),
                .select(DATA2[0]),
                .B(s0[i])
            );
        end
        MULTIPLEXER mux1_0 (
            .A0(DATA1[0]),
            .A1(fill[7]),
            .select(DATA2[0]),
            .B(s0[0])
        );
    endgenerate

    // Second layer: shift by 2
    generate
        for (i = 7; i > 1; i = i - 1) begin : second_layer
            MULTIPLEXER mux2 (
                .A0(s0[i]),
                .A1(s0[i-2]),
                .select(DATA2[1]),
                .B(s1[i])
            );
        end
        MULTIPLEXER mux2_1 (
            .A0(s0[1]),
            .A1(fill[7]),
            .select(DATA2[1]),
            .B(s1[1])
        );
        MULTIPLEXER mux2_0 (
            .A0(s0[0]),
            .A1(fill[6]),
            .select(DATA2[1]),
            .B(s1[0])
        );
    endgenerate

    // Third layer: shift by 4
    generate
        for (i = 7; i > 3; i = i - 1) begin : third_layer
            MULTIPLEXER mux3 (
                .A0(s1[i]),
                .A1(s1[i-4]),
                .select(DATA2[2]),
                .B(s2[i])
            );
        end
        MULTIPLEXER mux3_3 (
            .A0(s1[3]),
            .A1(fill[7]),
            .select(DATA2[2]),
            .B(s2[3])
        );
        MULTIPLEXER mux3_2 (
            .A0(s1[2]),
            .A1(fill[6]),
            .select(DATA2[2]),
            .B(s2[2])
        );
        MULTIPLEXER mux3_1 (
            .A0(s1[1]),
            .A1(fill[5]),
            .select(DATA2[2]),
            .B(s2[1])
        );
        MULTIPLEXER mux3_0 (
            .A0(s1[0]),
            .A1(fill[4]),
            .select(DATA2[2]),
            .B(s2[0])
        );
    endgenerate

    assign #2 OUTPUT = s2;
endmodule


`timescale 1ns/1ps

module SHIFT_tb;
    reg  [7:0] DATA1;
    reg  [2:0] DATA2;
    reg        SETPIN;
    wire [7:0] LEFT_OUT, RIGHT_OUT;

    // Instantiate modules
    LEFTshift uut1 (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .OUTPUT(LEFT_OUT)
    );

    RIGHTshift uut2 (
        .DATA1(DATA1),
        .DATA2(DATA2),
        .SETPIN(SETPIN),
        .OUTPUT(RIGHT_OUT)
    );

    initial begin
        $display("Time\tDATA1\t\tDATA2\tSETPIN\tLEFT_OUT\tRIGHT_OUT");

        // Test: Shift Left by 1
        DATA1 = 8'b10110011; DATA2 = 3'd1; SETPIN = 1'b1;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        // Test: Shift Left by 2
        DATA2 = 3'd2;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        // Test: Right Shift - Arithmetic
        DATA2 = 3'd1; SETPIN = 1'b1;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        // Test: Right Shift - Rotate
        SETPIN = 1'b0;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        // Edge Case: Shift by 0
        DATA2 = 3'd0;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        // Edge Case: Shift by 7
        DATA2 = 3'd7;
        #5 $display("%0t\t%b\t%0d\t%b\t%b\t%b", $time, DATA1, DATA2, SETPIN, LEFT_OUT, RIGHT_OUT);

        $finish;
    end
endmodule
