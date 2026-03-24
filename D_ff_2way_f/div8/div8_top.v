module div8_top
(
    input clk,
    input rst_n,

    output wire div8_clk_6_25MHz
);

wire clk_25MHz;

D_ff_2way_f D_ff_2way_f_1//调用子模块实例化
(
    .clk(clk),
    .rst_n(rst_n),

    .Q(clk_25MHz)
);

wire clk_12_5MHz;

D_ff_2way_f D_ff_2way_f_2
(
    .clk(clk_25MHz),
    .rst_n(rst_n),

    .Q(clk_12_5MHz)
);

D_ff_2way_f D_ff_2way_f_3
(
    .clk(clk_12_5MHz),
    .rst_n(rst_n),

  .Q(div8_clk_6_25MHz)//最后输出数据到顶层输出引脚
);
endmodule
