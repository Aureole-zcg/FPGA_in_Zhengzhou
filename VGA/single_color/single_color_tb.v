`timescale 1ns/1ps

module single_color_tb();

reg clk;
reg rst_n;

initial
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号

single_color single_color_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .HSYNC(), 
    .VSYNC(),
    .RGB565()
);
endmodule
