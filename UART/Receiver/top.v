module top
(
    input wire  clk, rst_n, rx,

    output wire led, out
);
wire [7:0]data;
wire      flag;

receiver receiver_inst
(
    .rx   (rx   ), 
    .clk  (clk  ), 
    .rst_n(rst_n),

    . out_data(data),
    . out_flag(flag)
);

//led测试接收信号
act_led act_led_inst
( 
    . clk  (clk  ), 
    . rst_n(rst_n),
    . data (data ),

    .led(led)
);

transmitter transmitter_inst
(
    .clk  (clk  ),
    .rst_n(rst_n),
    .data     (data),
    .data_flag(flag),

    . tx(out)
);
endmodule