//调用双端口RAM,读写共用1个时钟，数据输入输出位宽相等，将RAM写满随机数，实现FFTSHIFT功能
module RAM_test5
(
    input wire clk, wren, rden, 
    input wire [4:0] wraddr, //0~255
	 input wire [3:0]data,
    input wire [4:0] rdaddr, 
    input wire rst_n,

    output wire [3:0] q
);

ram4x32_4	ram4x32_4_inst (
   .clock     ( clk ),
	.data      ( data ),
	.rdaddress ( rdaddr ),
	.rden      ( rden ),
	.wraddress ( wraddr ),
	.wren      ( wren ),
	
	.q         ( q )
	);



endmodule
