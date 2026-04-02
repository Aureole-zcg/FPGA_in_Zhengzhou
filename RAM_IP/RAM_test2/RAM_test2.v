//8进16出
module RAM_test2
(
    input wire wrclk, wren, 
    input wire [7:0] wraddr, data,
    input wire rdclk, rden, 
    input wire [6:0] rdaddr, 
    input wire rst_n,

    output wire [15:0] q
);

ram_8x256_16	ram_8x256_16_inst (
	.data      ( data ),
	.rdaddress ( rdaddr ),
	.rdclock   ( rdclk ),
	.rden      ( rden ),
	.wraddress ( wraddr ),
	.wrclock   ( wrclk ),
	.wren      ( wren ),
	.q         ( q )
	);



endmodule
