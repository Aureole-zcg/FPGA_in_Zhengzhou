`timescale 1ns/1ps

module top_tb();



reg [7:0]A ;
reg [7:0]B ;
reg [7:0]C ;
reg [7:0]D ;
reg [7:0]E ;
reg [7:0]F ;
wire [26:0]Y ;

initial 
begin
    A=8'd0;//信号初始化 8位宽下十进制的0
    B=8'd0;
    C=8'd0;
    D=8'd0;
    E=8'd0;
    F=8'd0;
end

//系统函数 $random 随机产生一个32位有符号随机数
//{$rndom}:产生一个32位无符号随机数
//{$random}%256:ABCD只要八位，限制位宽 对位宽取余 产生一个0~255无符号随机数

//赋值关键字
always #100 A={$random}%256;
always #100 B={$random}%256;
always #100 C={$random}%256;
always #100 D={$random}%256;
always #100 E={$random}%256;
always #100 F={$random}%256;//每隔100nsABCD随机产生一个0~256无符号随机数

top top_inst
(
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .E(E),
    .F(F)
);
endmodule
