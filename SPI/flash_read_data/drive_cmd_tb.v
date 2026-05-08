//无按键的tb
`timescale 1ns/1ps

module drive_cmd_tb();
reg       div_clk         ;//SPI使用分频过的低频时钟
reg       rst_n           ;
reg        MISO;
//reg       spi_en          ;//SPI使能标志
//reg [1:0] spi_cmd         ;//命令输入
//reg [7:0] spi_wrdata      ;//输入数据
//reg [7:0] spi_wrdata_width;//输入数据宽度

initial begin
    div_clk = 1'b0;
    rst_n = 1'b0;
    #77
    rst_n = 1'b1;
end

always #50 div_clk = ~div_clk;//10MHz

//defparam top_inst.data_ctrl_inst.MAX_1S = 10_000;//仿真加速
defparam MOSIx8_inst.MAX_1S = 10_000;

MOSIx8 MOSIx8_inst
(
    . div_clk  (div_clk  ), 
    . rst_n    (rst_n    ),
    . MISO(MISO),

    . spi_clk  (),//spi输出时钟
    . cs_n     (),//片选信号
    . spi_MOSI ()//单bit串行数据
    //. data_done()//配置寄存器数据发送完毕标志位
);
endmodule
