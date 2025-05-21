// Creat the testbench module
module testbench;
    // Declare the Operand1 and operand2 as signed 8-bit register
    reg signed[7:0]OPERAND1,OPERAND2;

    // Declare ALUOP as 3-bit register to contro; ALU operation
    reg[2:0]ALUOP;

    // ALURESULT is an 8-bit signed wire for the output of the ALU
    wire signed[7:0] ALURESULT;
    
    // Instantiate the ALU modul
    alu uut(OPERAND1,OPERAND2,ALURESULT,ALUOP);
    

    // Creat the initial block for simulation
    initial begin
        // Display output whenever there is any change in operands or ALU operation
        $monitor("TIME=%0t : OP1:%0d OP2:%0d ALUOP:%0b RESULT:%0d(%8b)", $time, OPERAND1, OPERAND2, ALUOP, ALURESULT,ALURESULT);
        
        //Create waveform dump files
        $dumpfile("part1.vcd");
        $dumpvars(0,testbench);

        // Test Forward Operation (ALUOP = 000)
        OPERAND1=8'd0;  
        OPERAND2=8'd65;
        ALUOP  =3'b000;
        #10;   // add 10 time units delay

        // Test ADD Operation (ALUOP = 001)
        OPERAND1=8'd45;
        OPERAND2=8'd30;
        ALUOP  =3'b001;
        #10;   

        // Test AND Operation (ALUOP = 010)
        OPERAND1=8'b00100110;
        OPERAND2=8'b00111010;
        ALUOP  =3'b010;
        #10;   

        // Test OR Operation (ALUOP = 011)
        ALUOP  =3'b011;   
        #10;
        
        //Finish the simulation
        $finish;  
        
    end
    
endmodule




// FORWARD operation module
// Passes DATA2 directly to RESULT
module FORWARD(DATA2,RESULT);
    input signed [7:0]DATA2;
    output reg signed [7:0] RESULT;
    
    // Update RESULT whenever DATA2 changes (delay 1 time unit)
    always @(DATA2) begin
        #1 RESULT=DATA2;
    end
endmodule



// ADD operation module
// Adds DATA1 and DATA2 and outputs the result
module ADD(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed [7:0]DATA2;
    output reg signed  [7:0]RESULT;
   
    // Update RESULT as the sum of DATA1 and DATA2 (delay 2 time units)
    always @(DATA1,DATA2) begin
        #2 RESULT=DATA1+DATA2;
    end

endmodule



// AND operation module
// Performs bitwise AND between DATA1 and DATA2
module AND(DATA1,DATA2,RESULT);
    input signed [7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
    // Update RESULT with bitwise AND of DATA1 and DATA2 (delay 1 time unit)
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1&DATA2;
    end

endmodule


// OR operation module
// Performs bitwise OR between DATA1 and DATA2
module OR(DATA1,DATA2,RESULT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    output reg signed[7:0]RESULT;
    
   // Update RESULT with bitwise OR of DATA1 and DATA2 (delay 1 time unit)
    always @(DATA1,DATA2) begin
        #1 RESULT=DATA1|DATA2;
    end
    

endmodule


// 4-to-1 multiplexer module
// Selects one of the 4 inputs based on SELECT signal
module mux(I0,I1,I2,I3,SELECT,RESULT);
    input signed [7:0]I0,I1,I2,I3;
    input [2:0] SELECT;
    output reg signed[7:0] RESULT;

    // Update RESULT based on SELECT value
    always@(I0,I1,I2,I3,SELECT) begin
        case (SELECT)
            3'b000:  RESULT=I0; // FORWARD output  
            3'b001:  RESULT=I1; // ADD ouput
            3'b010:  RESULT=I2; // AND ouput
            3'b011:  RESULT=I3; // OR output 
            default: RESULT=0;
        endcase
    end 


endmodule

// ALU module
// Connects operation modules and uses multiplexer to select final result
module alu(DATA1,DATA2,RESULT,SELECT);
    input signed[7:0]DATA1;
    input signed[7:0]DATA2;
    input [2:0]SELECT;
    output signed[7:0]RESULT;

    // Internal wires for operation outputs
    wire signed [7:0]I0,I1,I2,I3;

    // Instantiate each operation module
    FORWARD uut(DATA2,I0);
    ADD add_unit(DATA1,DATA2,I1);
    AND and_unit(DATA1,DATA2,I2);
    OR or_unit(DATA1,DATA2,I3);
    // RESERVED res_unit();
    
    // Instantiate multiplexer to select one of the operation outputs
    mux mux_unit(I0,I1,I2,I3,SELECT,RESULT);

endmodule
