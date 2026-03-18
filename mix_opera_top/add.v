module add
(
    input wire[7:0] add_in1,//不写位宽默认为1
    input wire[7:0] add_in2,
    input wire[7:0] add_in3,

    output wire [9:0]add_out

);

assign add_out=add_in1+add_in2+add_in3;
endmodule
