//32进8出,由16位宽进8出修改
module RAM_test3
(
    input wire clk, wren, rden, 
    input wire [7:0] wraddr, //0~255
	 input wire [31:0]data,
    input wire [9:0] rdaddr, 
    input wire rst_n,

    output wire [7:0] q
);

ram_16x256_8	ram_16x256_8_inst (
   .clock     ( clk ),
	.data      ( data ),
	.rdaddress ( rdaddr ),
	.rden      ( rden ),
	.wraddress ( wraddr ),
	.wren      ( wren ),
	
	.q         ( q )
	);



endmodule
