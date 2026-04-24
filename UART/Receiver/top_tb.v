`timescale 1ns/1ps

module top_tb();

reg clk;
reg rst_n;
reg rx;

initial
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    rx=1'b1;
    #77
    rst_n=1'b1;//系统正常
    rx=1'b1;
    #(5208*20)
    rx=1'b0;//空闲位
    #(5208*20)//8:0001_0000
    rx=1'b0;
    #(5208*20)
    rx=1'b0;
    #(5208*20)
    rx=1'b0;
    #(5208*20)
    rx=1'b1;
    #(5208*20)
    rx=1'b0;
    #(5208*20)
    rx=1'b0;
    #(5208*20)
    rx=1'b0;
    #(5208*20)
    rx=1'b0;
    #(5208*20)//停止位
    rx=1'b1;

end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号

defparam top_inst.transmitter_inst. SYS_CLK = 50_000_0;
defparam top_inst.transmitter_inst.UART_BPS = 96;

top top_inst
(
    .clk(clk),
    .rst_n(rst_n),
    .rx   (rx   ),

    .led(),
    .out()
);
endmodule