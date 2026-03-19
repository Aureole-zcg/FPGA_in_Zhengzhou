`timescale 1ns/1ps

module D_ff_2way_f_tb();
reg D;
reg clk;
reg rst_n;
wire Q;

initial
begin
    D=1'b0;
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号
always @(Q)  D<=~Q;


D_ff_2way_f D_ff_2way_f_inst
(
    .D(D),
    .clk(clk),
    .rst_n(rst_n),

    .Q(Q)
);
endmodule
