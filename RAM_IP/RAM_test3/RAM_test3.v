//16位宽进8出
module RAM_test3
(
    input wire wrclk, wren, 
    input wire [7:0] wraddr, //0~255
	input wire [15:0]data,
    input wire rdclk, rden, 
    input wire [8:0] rdaddr, 
    input wire rst_n,

    output wire [7:0] q
);

ram_16x256_8	ram_16x256_8_inst (
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
