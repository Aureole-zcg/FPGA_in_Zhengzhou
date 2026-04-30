`timescale 1ns/1ps

module top_tb();
reg       clk_10MHz         ;//SPI使用分频过的低频时钟
reg       rst_n           ;
//reg       spi_en          ;//SPI使能标志
//reg [1:0] spi_cmd         ;//命令输入
//reg [7:0] spi_wrdata      ;//输入数据
//reg [7:0] spi_wrdata_width;//输入数据宽度

initial begin
    clk_10MHz = 1'b0;
    rst_n = 1'b0;
    #77
    rst_n = 1'b1;
end

always #50 clk_10MHz = ~clk_10MHz;//10MHz

defparam top_inst.data_ctrl_inst.MAX_1S = 10_000;//仿真加速

top top_inst
(
    . clk_10MHz(clk_10MHz), 
    . rst_n    (rst_n    ),

    . spi_clk  (),//spi输出时钟
    . cs_n     (),//片选信号
    . spi_MOSI (),//单bit串行数据
    . data_done()//配置寄存器数据发送完毕标志位
);
endmodule
