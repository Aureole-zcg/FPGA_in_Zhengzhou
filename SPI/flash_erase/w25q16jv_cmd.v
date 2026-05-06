
module w25q16jv_cmd
(
	input wire [7:0] index,//索引

	output wire [7:0] spi_wrdata
);


wire [7:0] cmd_data[0:1];
   //assign cmd_data[0] = {8'h06};//写使能
   //assign cmd_data[1] = {8'hc7};//芯片擦除
assign cmd_data[0] = {8'h06};//写使能
assign cmd_data[1] = {8'hc7};//芯片擦除


assign spi_wrdata = cmd_data[index];


endmodule 










