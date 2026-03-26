module breath_led_tb
();
    reg clk;
    reg rst_n;//50MHz，低电平复位

    wire led_out;

initial begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号

breath_led 
#(
    .S_MS_MAX(16'd99),
    .US_MAX(16'd4)
)
breath_led_inst
(
    . clk(clk),
    . rst_n(rst_n),//50MHz，低电平复位

    .led_out(led_out)
);
endmodule
