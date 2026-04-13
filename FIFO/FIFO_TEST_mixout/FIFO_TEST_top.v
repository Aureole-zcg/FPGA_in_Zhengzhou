module FIFO_TEST_top
(
    input wire        clk  ,
    input wire        rst_n,
    input wire [15:0] DATA ,
	 input wire        wrreq,

    output wire [15:0] q_reverse,
    output wire [15:0] q_max    ,
    output wire [10:0] addr_max ,
    output wire [15:0] q_fft
);

wire [15:0] q_fifo;
wire flag_fifo_rams1;
fifo fifo_inst
(
    . clk        (clk  ),
    . rst_n      (rst_n),
    . wrreq      (wrreq),
    . data       (DATA ),

    . q_fifo(q_fifo),
    . flag_fifo_rams1(flag_fifo_rams1)//用于传递信号,使fifo结束后，启动单通道ram，同步reque
);


wire [15:0] q_ram_s;
wire flag_rams1_ramdbl;
ram_single ram_single_inst
(
    . clk   (clk  ),
    . rst_n (rst_n),
    . q_fifo(q_fifo),
    . flag_fifo_rams1(flag_fifo_rams1),//用于传递信号,使fifo结束后，启动单通道ram，同步reque

    . q_ram_s(q_ram_s),
    . flag_rams1_ramdbl(flag_rams1_ramdbl)
);


wire [15:0] q_ram_dbl;
wire flag_ramdbl_rden;
ram_dbl_reverse ram_dbl_reverse_inst
(
    . clk              (clk  ),
    . rst_n            (rst_n),
    . q_ram_s          (q_ram_s),
    . flag_rams1_ramdbl(flag_rams1_ramdbl),//用于传递信号,使rams1结束后，启动双通道ram，同步wren

    . q_reverse(q_reverse)
    //. flag_ramdbl_rden(flag_ramdbl_rden)
);

ram_dbl_compare ram_dbl_compare_inst
(
    . clk              (clk  ),
    . rst_n            (rst_n),
    . q_ram_s          (q_ram_s),
    . flag_rams1_ramdbl(flag_rams1_ramdbl),//用于传递信号,使rams1结束后，启动双通道ram，同步wren

    . q_ram_dbl(q_ram_dbl),
    . flag_ramdbl_rden(flag_ramdbl_rden)
);

ram_dbl_fftshift ram_dbl_fftshift_inst
(
    . clk              (clk              ),
    . rst_n            (rst_n            ),
    . q_ram_s          (q_ram_s          ),
    . flag_rams1_ramdbl(flag_rams1_ramdbl),//用于传递信号,使rams1结束后，启动双通道ram，同步wren

    . q_fftshift(q_fft)
    //output wire flag_ramdbl_rden
);

//wire [15:0] q_reverse_r;
//reverse reverse_inst
//(
//    . clk             (clk             ),
//    . rst_n           (rst_n           ),
//    .  data_ram_in    (q_ram_dbl       ),
//    . flag_ramdbl_rden(flag_ramdbl_rden),
//
//    . q_reverse(q_reverse_r)
//);
//assign q_reverse = q_reverse_r;
//
compare_size compare_size_inst
(
    . clk             (clk             ),
    . rst_n           (rst_n           ),
    .  data_ram_in    (q_ram_dbl       ),
    . flag_ramdbl_rden(flag_ramdbl_rden),

    . q_max    (q_max   ),
    . addr_max (addr_max)
);
//
//fftshift fftshift_inst
//(
//    . clk             (clk             ),
//    . rst_n           (rst_n           ),
//    . data_ram_in     (q_ram_dbl       ),
//    . flag_ramdbl_rden(flag_ramdbl_rden),
//
//    . q_fft (q_fft)
//);

endmodule
