`timescale 1ns/1ps

module top_test_tb();

reg clk_20MHz ;
reg clk_15MHz ;
reg clk_50MHz ;
reg clk_100MHz;
reg rst_n     ;

initial
begin
    clk_20MHz=1'b0; 
    clk_15MHz=1'b0; 
    clk_50MHz=1'b0; 
    clk_100MHz=1'b0;
    rst_n=1'b0;//系统复位
    #77
    rst_n=1'b1;//系统正常
end

//clk:20MHz  T=50ns
always #25 clk_20MHz=~clk_20MHz;//获取周期稳定震荡的时钟信号
//clk:15MHz  T=66ns
always #33 clk_15MHz=~clk_15MHz;
//clk:50MHz  T=20ns
always #10 clk_50MHz=~clk_50MHz;
//clk:100MHz  T=10ns
always #5 clk_100MHz=~clk_100MHz;

top_test top_test_inst
(
    . clk_20MHz ( clk_20MHz ),
    . clk_15MHz ( clk_15MHz ),
    . clk_50MHz ( clk_50MHz ),
    . clk_100MHz( clk_100MHz),
    . rst_n     ( rst_n     ),

    . package_data(),
    . data_valid  ()
);
endmodule
