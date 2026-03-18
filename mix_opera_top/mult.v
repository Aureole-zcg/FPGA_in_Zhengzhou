module mult
(
    input wire[9:0] mult_in1,
    input wire[8:0] mult_in2,
    input wire[7:0] mult_in3,

    output wire [26:0]mult_out

);

assign mult_out=mult_in1*mult_in2*mult_in3;
endmodule
