`timescale 1ns/1ps

module flash_led1_3_tb();
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

flash_led1_3 
#(
    .CNT1_MAX(16'd49),//
    .CNT2_MAX(16'd4) //
)
flash_led1_3_inst
(
    .clk(clk),
    .rst_n(rst_n),

    .led(led)

);

endmodule
