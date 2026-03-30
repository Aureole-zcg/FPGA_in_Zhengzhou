`timescale 1ns/1ps

module fsm_10010_tb();

reg clk;
reg rst_n;
reg data_in;
wire flag;

initial
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号
always #20 data_in = {$random} % 2;//产生随机信号，速度与时钟匹配一直，以数据防漏采或多采

fsm_10010 
#(
.idle ( 4'd0),
.s0   ( 4'd1),
.s1   ( 4'd2),
.s2   ( 4'd3),
.s3   ( 4'd4),
.s4   ( 4'd5)
)
fsm_10010_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .flag(flag)
);

endmodule
