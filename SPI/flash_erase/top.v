module top
(
    input wire clk_10MHz, rst_n,

    output wire spi_clk,//spi输出时钟
    output wire cs_n,//片选信号
    output wire spi_MOSI//单bit串行数据
    //output wire data_done//配置寄存器数据发送完毕标志位
);

//wire [23:0] data;
//wire spi_en;
//wire [7:0] data_width;
//wire [1:0] spi_cmd;
//wire spi_done;
//
//data_ctrl data_ctrl_inst
//(
//   . clk_10MHz(clk_10MHz),
//   . rst_n    (rst_n    ),//T=100ns
//   . flag_done(spi_done ),
//
//    . data      (data      ),
//    . spi_en    (spi_en    ),
//    . data_width(data_width),
//    . spi_cmd   (spi_cmd   ),
//    . data_done (data_done )
//);

//MOSIx24 MOSIx24_inst
//(
//    . div_clk         (clk_10MHz ),//SPI使用分频过的低频时钟
//    . rst_n           (rst_n     ),
//    . spi_en          (spi_en    ),//SPI使能标志
//    . spi_cmd         (spi_cmd   ),//命令输入
//    . spi_wrdata      (data      ),//输入数据
//    . spi_wrdata_width(data_width),//输入数据宽度
//
//    . spi_clk (spi_clk ),//spi输出时钟
//    . cs_n    (cs_n    ),//片选信号
//    . spi_MOSI(spi_MOSI),//单bit串行数据
//    . spi_done(spi_done) //信号传输完毕标志信号
//);

wire [7:0] data;
wire spi_en;
wire [7:0] data_width;
wire [1:0] spi_cmd;
wire spi_done;
wire data_done;//配置寄存器数据发送完毕标志位

flash_ctrl flash_ctrl_inst
(
    . clk_10MHz(clk_10MHz),
    . rst_n    (rst_n    ),//T=100ns
    . flag_done(spi_done ),

    . data      (data      ),
    . spi_en    (spi_en    ),
    . data_width(data_width),
    . spi_cmd   (spi_cmd   ),
    . data_done (data_done )                  
);

MOSIx8 MOSIx8_inst
(
    . div_clk         (clk_10MHz ),//SPI使用分频过的低频时钟
    . rst_n           (rst_n     ),
    . spi_en          (spi_en    ),//SPI使能标志
    . spi_cmd         (spi_cmd   ),//命令输入
    . spi_wrdata      (data      ),//输入数据
    . spi_wrdata_width(data_width),//输入数据宽度

    . spi_clk (spi_clk ),//spi输出时钟
    . cs_n    (cs_n    ),//片选信号
    . spi_MOSI(spi_MOSI),//单bit串行数据
    . spi_done(spi_done) //信号传输完毕标志信号
);
endmodule
