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

ram_16x256_8	ram_16x256_8_inst //配置完IP核生成的.qip文件会生成IP核对应的.v文件和单独的IP核_inst文件，ram_16x256_8_inst是_inst文件的内容复制过来
	(
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
