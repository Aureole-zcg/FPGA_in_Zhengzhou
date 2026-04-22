`timescale 1ns/1ps

module transmitter_tb();

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

defparam transmitter_inst.data_genaration_inst.MAX_1s = 49_999_9;
defparam transmitter_inst.                    SYS_CLK = 50_000_0;
defparam transmitter_inst.                   UART_BPS = 96;

transmitter transmitter_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .tx()
);
endmodule
