`timescale 1ns/1ps

module cnt_ctrl_tb();
    reg  clk;
    reg rst_n;

    wire Y;


initial
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

always #10 clk=~clk;//获取周期稳定震荡的时钟信号

cnt_ctrl cnt_ctrl_inst
(
    .clk(clk),
    .rst_n(rst_n),

  .Y(Y)//不给中间变量Y_test写实例端口赋值，模拟时打开实例化的模型图有中间变量波形

);

endmodule
