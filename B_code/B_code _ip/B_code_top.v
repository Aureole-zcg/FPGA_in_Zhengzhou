module B_code_top
(
    input wire clk, rst_n,
    output wire [3:0] second_ones  ,
    output wire [2:0] second_tens  ,
    output wire [3:0] minute_ones  ,
    output wire [2:0] minute_tens  ,
    output wire [3:0] hour_ones    ,
    output wire [1:0] hour_tens    ,
    output wire [3:0] day_ones     ,
    output wire [3:0] day_tens     ,
    output wire [1:0] day_hundreds ,
    output wire [3:0] year_ones    ,
    output wire [3:0] year_tens    
);

//定义转接线
wire clk_125MHz ;//125MHz时钟
wire locked;//锁定信号
wire B_code_out  ;//B码输出


pll_ip_B	pll_ip_B_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( clk_125MHz ),
	.locked ( locked )
	);

 B_generation 
 #(
        									   //125Mhz时钟计算时长
    .time_10ms ( 32'd1249_999 ),//码元长度
    .time_8ms  ( 32'd999_999  ),//P码高电平时间
    .time_5ms  ( 32'd624_999  ),//1码高电平时间
    .time_2ms  ( 32'd249_999  ) //0码高电平时间 
 )
 B_generation_inst
(
    .clk_125MHz(clk_125MHz), //125Mhz时钟
	.rst_n(locked),//PLL——IP核输出的锁定信号locked在输出时钟稳定后拉高，与rst_n在不复位时也为高电平相同，所以可以代替掉rst_n
    .B_code_out(B_code_out)//输出B码
);

B_code_v2
#(
    .TIME_8MS (32'd999_999),
    .TIME_5MS (32'd624_999),
    .TIME_2MS (32'd249_999),
    .error(32'd1000)//8us;
)
B_code_v2_inst
(
    .clk_125MHz(clk_125MHz)     ,
    .rst_n     (locked),
    .B_code_in (B_code_out ),
    
    .second_ones  (second_ones ),
    .second_tens  (second_tens ),
    .minute_ones  (minute_ones ),
    .minute_tens  (minute_tens ),
    .hour_ones    (hour_ones   ),
    .hour_tens    (hour_tens   ),
    .day_ones     (day_ones    ),
    .day_tens     (day_tens    ),
    .day_hundreds (day_hundreds),
    .year_ones    (year_ones   ),
    .year_tens    (year_tens   ) 

);
endmodule
