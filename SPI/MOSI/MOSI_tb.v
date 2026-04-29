`timescale 1ns/1ps

module MOSI_tb();
reg       div_clk         ;//SPI使用分频过的低频时钟
reg       rst_n           ;
reg       spi_en          ;//SPI使能标志
reg [1:0] spi_cmd         ;//命令输入
reg [7:0] spi_wrdata      ;//输入数据
reg [7:0] spi_wrdata_width;//输入数据宽度

initial begin
    div_clk = 1'b0;
    rst_n = 1'b0;
    spi_en           = 1'b0;
    spi_cmd          = 2'b00;
    spi_wrdata       = 8'd0;
    spi_wrdata_width = 8'd0;
    #77
    rst_n = 1'b1;
    #1228
    spi_en = 1'b1;
    spi_wrdata = 8'b10101010;
    #40
    spi_en = 1'b0;
    spi_wrdata = 8'b10101010;
end

always #20 div_clk = ~div_clk;//25MHz

MOSI MOSI_inst
(
    . div_clk         (div_clk         ),//SPI使用分频过的低频时钟
    . rst_n           (rst_n           ),
    . spi_en          (spi_en          ),//SPI使能标志
    . spi_cmd         (spi_cmd         ),//命令输入
    . spi_wrdata      (spi_wrdata      ),//输入数据
    . spi_wrdata_width(spi_wrdata_width),//输入数据宽度

    . spi_clk (),//spi输出时钟
    . cs_n    (),//片选信号
    . spi_MOSI(),//单bit串行数据
    . spi_done() //信号传输完毕标志信号
);
endmodule
