`timescale 1ns/1ps

module mux4_1_tb();
    reg [7:0]add_in0;
    reg [7:0]add_in1;
    reg [7:0]add_in2;
    reg [7:0]add_in3;
    reg [1:0]sel;

    wire [7:0]add_out;

initial begin
    add_in0=8'd0;
    add_in1=8'd0;
    add_in2=8'd0;
    add_in3=8'd0;
    sel=2'd0;
end

always #100 add_in0={$random}%256;
always #100 add_in1={$random}%256;
always #100 add_in2={$random}%256;
always #100 add_in3={$random}%256;
always #33.33 sel={$random}%4;

mux4_1 mux4_1_inst
(
    .add_in0(add_in0),
    .add_in1(add_in1),
    .add_in2(add_in2),
    .add_in3(add_in3),
    .sel(sel),

    .add_out(add_out)

);
endmodule
