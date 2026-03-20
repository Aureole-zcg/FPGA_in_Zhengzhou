`timescale 1ns/1ps

module flash_led_tb();
    reg  clk;
    reg rst_n;

    wire led;


initial
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

always #10 clk=~clk;//获取周期稳定震荡的时钟信号

flash_led 
#(
  .CNT_MAX(32'd5000) //10ms,即模拟时5ms信号跳变一次加速，以此模拟进程
)
flash_led_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .led(led)

);

endmodule
