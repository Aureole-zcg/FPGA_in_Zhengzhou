`timescale 1ns/1ps

module ram_test6_tb();
reg clk;
reg rst_n;

initial 
begin
    clk=1'b0;
    rst_n=1'b0;//系统复位
    #100
    rst_n=1'b1;//系统正常
end

//clk:50MHz  T=20ns
always #10 clk=~clk;//获取周期稳定震荡的时钟信号

ram_test6 ram_test6_inst
(
    .clk(clk), 
    .rst_n(rst_n), 

    .q_a(), 
    .q_b()
);

endmodule
