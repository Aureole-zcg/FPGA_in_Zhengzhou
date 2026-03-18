module top
(
    input wire[7:0] A,
    input wire[7:0] B,
    input wire[7:0] C,
    input wire[7:0] D,
    input wire[7:0] E,
    input wire[7:0] F,

    output wire [26:0] Y

);
  
//定义转接线
wire [9:0]add_mult1 ;
wire [8:0]add_mult2 ;
wire [7:0]sub_mult ;

  add add_1//第一次调用加法模块 add_1:(A+B+C)
(
    .add_in1(A),
    .add_in2(B),
    .add_in3(C),

    .add_out(add_mult1)
);

add add_2
(
    .add_in1(C),
    .add_in2(D),
    .add_in3(0),

    .add_out(add_mult2)
);

sub sub_1
(
    .sub_in1(E),
    .sub_in2(F),

    .sub_out(sub_mult)
);

mult mult_1//实例化乘法器并调用
(
    .mult_in1(add_mult1),
    .mult_in2(add_mult2),
    .mult_in3(sub_mult),

    .mult_out(Y)
);
endmodule
