`timescale 1ns/1ps

module d_ff_tb();
reg clk;
reg rst_n;
reg D;

wire Q;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    D=1'b0;
    #100
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号
always #33.33 D={$random}%2;

d_ff d_ff_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .D(D),

    .Q(Q)
);


endmodule
