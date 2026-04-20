module top_dynamic_DIG
(
    input wire clk, rst_n,

    output wire stcp, shcp, ds, oe_n//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);


wire [19:0] data  ; //0~999999,20bit
wire [5:0]  point ;//小数点
wire         sign ;//"-"负数符号
wire        seg_en;//段选使能
data_generation data_generation_inst
(
    . clk ( clk ), 
    .rst_n(rst_n),

    . data  (data  ), //0~999999,20bit
    . point (point ),//小数点
    .  sign ( sign ), //"-"负数符号
    . seg_en(seg_en)//段选使能
);

wire [3:0] one     ;
wire [3:0] ten     ;
wire [3:0] hundred ;
wire [3:0] thousend;
wire [3:0] ten_tho ;
wire [3:0] hun_tho ;
BCD8421_convert BCD8421_convert_inst
(
    . clk ( clk ), 
    .rst_n(rst_n),
    . data( data),

    . one     (one     ),
    . ten     (ten     ),
    . hundred (hundred ),
    . thousend(thousend),
    . ten_tho (ten_tho ),
    . hun_tho (hun_tho )
);

wire [5:0] sel;
wire [7:0] seg;
sel_seg_gen sel_seg_gen_inst
(
    . clk    (clk   ),
    . rst_n  (rst_n ),
    . data   (data  ),//from data_generation
    . point  (point ),
    . sign   (sign  ),
    . seg_en (seg_en),//高电平有效

    . sel(sel),
    . seg(seg) //串行
);
 
_74HC595 _74HC595_inst
(
   . clk  (clk  ), 
   . rst_n(rst_n),
   . sel  (sel  ),
   . seg  (seg  ),

   .stcp(stcp), 
   .shcp(shcp), 
   .ds  (ds  ), 
   .oe_n(oe_n)//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);
endmodule
