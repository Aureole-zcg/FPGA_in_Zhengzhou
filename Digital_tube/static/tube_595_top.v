module tube_595_top
(
    input wire clk, rst_n,

    output wire stcp, shcp, ds, oe_n
);

wire [5:0] sel;
wire [7:0] seg;

tube_driver
//#(
//    . MAX_500ms(25_000_000),//0.5s
//
//    . SEG_0(8'b1100_0000),
//    . SEG_1(8'b1111_1001),
//    . SEG_2(8'b1010_0100),
//    . SEG_3(8'b1011_0000),
//    . SEG_4(8'b1001_1001),
//    . SEG_5(8'b1001_0010),
//    . SEG_6(8'b1000_0010),
//    . SEG_7(8'b1111_1000),
//    . SEG_8(8'b1000_0000),
//    . SEG_9(8'b1001_0000),
//    . SEG_a(8'b1000_1000),
//    . SEG_b(8'b1000_0011),
//    . SEG_c(8'b1100_0110),
//    . SEG_d(8'b1010_0001),
//    . SEG_e(8'b1000_0110),
//    . SEG_f(8'b1000_1110)
//)
tube_driver_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),

    .  sel(sel),//select位选信号
    .  seg(seg)//segment段选信号
);

_74HC595 _74HC595_inst
(
   . clk  (clk  ),
   . rst_n(rst_n),
   .  sel(sel),//select位选信号
   .  seg(seg),//segment段选信号

    .stcp(stcp), 
    .shcp(shcp), 
    .ds  (ds  ), 
    .oe_n(oe_n)//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);

endmodule