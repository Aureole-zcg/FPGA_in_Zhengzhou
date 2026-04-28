module top
(
    input wire rx, clk, rst_n,

    output wire stcp, shcp, ds, oe_n//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);

wire [7:0] out_data;
wire       out_flag;
rx rx_inst
(
    . rx   (rx   ), 
    . clk  (clk  ),
    . rst_n(rst_n),

    . out_data(out_data),
    . out_flag(out_flag)
);

wire Y;
code code_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . flag   (out_flag),
    . data_in(out_data),

    . Y(Y)
);

wire [19:0] data_dec;
time_get time_get_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . Y      (Y      ),  
    . flag   (out_flag),
    . data_in(out_data),

    . data_dec(data_dec)
);


wire [3:0] one     ;
wire [3:0] ten     ;
wire [3:0] hundred ;
wire [3:0] thousend;
wire [3:0] ten_tho ;
wire [3:0] hun_tho ;
BCD8421_convert BCD8421_convert_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . data(data_dec),

    . one     (one     ),
    . ten     (ten     ),
    . hundred (hundred ),
    . thousend(thousend),
    . ten_tho (ten_tho ),
    . hun_tho (hun_tho )
);

wire [5:0] sel;
wire [7:0] seg;//串行
sel_seg_gen sel_seg_gen_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . data(data_dec),//from data_generation
    . point  (6'b001010),
    . sign   (0),
    . seg_en (1),//高电平有效

    . sel(sel),
    . seg(seg) //串行
);

_74HC595 _74HC595_inst
(
    . clk  (clk  ),
    . rst_n(rst_n),
    . sel(sel),
    . seg(seg),

    .stcp(stcp), 
    .shcp(shcp), 
    .ds  (ds  ), 
    .oe_n(oe_n)
);
endmodule
