module i2c_ctrl
#(
	parameter SLAVE_ADDR = 7'b1010_011		//从机地址
)(
	
	input wire iic_clk,				//1MHz时钟
	input wire rst_n,	
	input wire wren,				//写使能
	input wire rden,				//读使能 //可写成一个cmd命令
	input wire i2c_start,			//开始标志信号
	input wire addr_num,			//EEPROM字地址长度，为0代表1个字节，为1代表2个字节
	input wire [15:0] byte_addr,	//EEPROM写读的字地址
	input wire [7:0] wr_data,		//写数据

	output reg [7:0] rd_data,		//读数据
	output reg i2c_wr_rd_done,		//读写完成信号
	
	output reg IIC_SCL,				//IIC时钟线

	inout IIC_SDA					//IIC双向数据线 wire型
);
	
	reg sda_en;				//SDA使能信号，为1代表SDA作为输出，为0代表SDA作为输入
	reg sda_out;			//SDA作为输出
	wire sda_in;			//SDA作为输入
	
	//三态门形成inout
	assign IIC_SDA = (sda_en) ? sda_out : 1'dz;
	assign sda_in = IIC_SDA;
	
	reg [1:0] cnt_i2c_clk;		//0~3计数，为实现4分频得到250kHz的IIC总线变化
	reg [3:0] cnt_bit;			//发送或接收bit计数
	
	reg sda_in_reg;				//SDA应答信号寄存
	
	//状态编码
	parameter IDLE 			= 8'd0;
	parameter START_1 		= 8'd1;
	parameter SEND_D_ADDR 	= 8'd2;
	parameter ACK_1			= 8'd3;
	parameter SEND_B_ADDR_H = 8'd4;
	parameter ACK_2			= 8'd5;
	parameter SEND_B_ADDR_L = 8'd6;
	parameter ACK_3			= 8'd7;
	parameter WRITE_DATA 	= 8'd8;
	parameter ACK_4			= 8'd9;
	parameter START_2 		= 8'd10;
	parameter SEND_RD_ADDR 	= 8'd11;
	parameter ACK_5			= 8'd12;
	parameter READ_DATA 	= 8'd13;
	parameter N_ACK			= 8'd14;
	parameter STOP			= 8'd15;
	
	reg [7:0] state;
	
	//描述状态跳转
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					state <= IDLE;
				end
			else case(state)
				IDLE:
					begin
						if(i2c_start)
							begin
								state <= START_1;
							end
					end
				START_1:	//产生起始信号
					begin
						if(cnt_i2c_clk == 2'd3)
							begin
								state <= SEND_D_ADDR;
							end
					end
				SEND_D_ADDR:	//发送器件地址+ 1bit读写位（写）
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= ACK_1;
							end
					end
				ACK_1:			//从机应答
					begin
						if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0) && addr_num)	//判断从机有应答，EEPROM字地址长度为2个字节
							begin
								state <= SEND_B_ADDR_H;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0) && (~addr_num))
							begin
								state <= SEND_B_ADDR_L;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd1) )	//判断从机无应答，回到IDLE状态
							begin
								state <= IDLE;
							end	
					end
				SEND_B_ADDR_H:	//发送EEPROM字地址高八位
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= ACK_2;
							end
					end
				ACK_2:			//从机应答
					begin
						if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0))
							begin
								state <= SEND_B_ADDR_L;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd1) )	//判断从机无应答，回到IDLE状态
							begin
								state <= IDLE;
							end	
					end
				SEND_B_ADDR_L:	//发送EEPROM字地址低八位
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= ACK_3;
							end
					end
				ACK_3:			//从机应答
					begin
						if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0) && wren)	//判断为写操作
							begin
								state <= WRITE_DATA;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0) && rden)	//判断为读操作
							begin
								state <= START_2;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd1) )	//判断从机无应答，回到IDLE状态
							begin
								state <= IDLE;
							end
					end
				WRITE_DATA:		//写入数据
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= ACK_4;
							end
					end
				ACK_4:			//从机应答
					begin
						if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0))
							begin
								state <= STOP;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd1) )	//判断从机无应答，回到IDLE状态
							begin
								state <= IDLE;
							end	
					end
				START_2:		//再次发送起始信号
					begin
						if(cnt_i2c_clk == 2'd3)
							begin
								state <= SEND_RD_ADDR;
							end
					end
				SEND_RD_ADDR:	//发送器件地址 + 1bit读写位（读）
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= ACK_5;
							end
					end
				ACK_5:			//从机应答
					begin
						if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd0))
							begin
								state <= READ_DATA;
							end
						else if((cnt_i2c_clk == 2'd3) && (sda_in_reg == 1'd1) )	//判断从机无应答，回到IDLE状态
							begin
								state <= IDLE;
							end
					end
				READ_DATA:		//从机发送读出数据，主机接收
					begin
						if((cnt_i2c_clk == 2'd3) && (cnt_bit == 4'd7))
							begin
								state <= N_ACK;
							end
					end
				N_ACK:			//主机非应答
					begin
						if(cnt_i2c_clk == 2'd3)
							begin
								state <= STOP;
							end
					end
				STOP:			//主机发送停止信号
					begin
						if(cnt_i2c_clk == 2'd3)
							begin
								state <= IDLE;
							end
					end
				default:
					begin
						state <= IDLE;
					end
			endcase
		end
	
	//描述cnt_i2c_clk 0~3计数，为实现4分频得到250kHz的IIC总线变化
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					cnt_i2c_clk <= 2'd0;
				end
			else if(state == IDLE)
				begin
					cnt_i2c_clk <= 2'd0;
				end
			else
				begin
					cnt_i2c_clk <= cnt_i2c_clk + 1'd1;
				end
		end
	
	//描述cnt_bit 0~7计数，发送或接收bit数
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					cnt_bit <= 4'd0;
				end
			else if((state == SEND_D_ADDR) || (state == SEND_B_ADDR_H)
					|| (state == SEND_B_ADDR_L) || (state == WRITE_DATA)
					|| (state == SEND_RD_ADDR) || (state == READ_DATA))
				begin
					if(cnt_i2c_clk == 2'd3)
						begin
							cnt_bit <= cnt_bit + 1'd1;
						end
				end
			else
				begin
					cnt_bit <= 4'd0;
				end
		end
	
	//描述IIC_SCL
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					IIC_SCL <= 1'd1;
				end
			else if((state == IDLE) || (state == STOP))
				begin
					IIC_SCL <= 1'd1;
				end
			else if((cnt_i2c_clk == 2'd2) || (cnt_i2c_clk == 2'd3))
				begin
					IIC_SCL <= 1'd0;
				end
			else
				begin
					IIC_SCL <= 1'd1;
				end
		end
	
	//描述SDA作为输出 sda_out
	wire [7:0] D_ADDR_W;	//器件地址+写
	
	assign D_ADDR_W = {SLAVE_ADDR,1'd0};
	
	wire [7:0] D_ADDR_R;	//器件地址+读
	
	assign D_ADDR_R = {SLAVE_ADDR,1'd1};
	
	always @ (*)
		begin
			if(~rst_n)
				begin
					sda_out = 1'd1;
				end
			else case(state)
				IDLE:
					begin
						sda_out = 1'd1;
					end
				START_1:	//发送起始信号
					begin
						if((cnt_i2c_clk == 2'd2) || (cnt_i2c_clk == 2'd3))
							begin
								sda_out = 1'd0;
							end
						else
							begin
								sda_out = 1'd1;
							end
					end
				SEND_D_ADDR:	//发送器件地址 1bit读写位（写）
					begin
						sda_out = D_ADDR_W[7 - cnt_bit];
					end
				SEND_B_ADDR_H:	//发送EEPROM字地址高八位
					begin
						sda_out = byte_addr[15 - cnt_bit];
					end
				SEND_B_ADDR_L:	//发送EEPROM字地址低八位
					begin
						sda_out = byte_addr[7 - cnt_bit];
					end
				WRITE_DATA:		//发送写数据
					begin
						sda_out = wr_data[7 - cnt_bit];
					end
				START_2:		//发送起始信号
					begin
						if((cnt_i2c_clk == 2'd2) || (cnt_i2c_clk == 2'd3))
							begin
								sda_out = 1'd0;
							end
						else
							begin
								sda_out = 1'd1;
							end
					end
				SEND_RD_ADDR:	//发送器件地址 1bit读写位（读）
					begin
						sda_out = D_ADDR_R[7 - cnt_bit];
					end
				STOP:			//发送停止信号
					begin
						if((cnt_i2c_clk == 2'd0) || (cnt_i2c_clk == 2'd1))
							begin
								sda_out = 1'd0;
							end
						else
							begin
								sda_out = 1'd1;
							end
					end
				N_ACK:			//发送非应答
					begin
						sda_out = 1'd1;
					end
				ACK_1,ACK_2,ACK_3,ACK_4,ACK_5,READ_DATA:
					begin
						sda_out = 1'd1;
					end
				default:
					begin
						sda_out = 1'd1;
					end
			endcase
		end
	
	//描述sda_in_reg寄存应答信号
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					sda_in_reg <= 1'd1;
				end
			else if((state == ACK_1) || (state == ACK_2)
					|| (state == ACK_3) || (state == ACK_4)
					||	(state == ACK_5))
				begin
					if(cnt_i2c_clk == 2'd0)
						begin
							sda_in_reg <= sda_in;		//寄存应答信号
						end
					else
						begin
							sda_in_reg <= sda_in_reg;
						end
				end
			else
				begin
					sda_in_reg <= 1'd1;
				end
		end
	
	//描述sda_en使能信号
	always @ (*)
		begin
			if((state == ACK_1) || (state == ACK_2)
					|| (state == ACK_3) || (state == ACK_4)
					||	(state == ACK_5) || (state == READ_DATA))
				begin
					sda_en = 1'd0;
				end
			else
				begin
					sda_en = 1'd1;
				end
		end
	
	//读出数据
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					rd_data <= 8'd0;
				end
			else if(state == READ_DATA)
				begin
					if(cnt_i2c_clk == 2'd1)
						begin
							rd_data <= {rd_data[6:0],sda_in};
						end
				end
			else
				begin
					rd_data <= rd_data;
				end
		end
	
	//写读操作完成信号
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					i2c_wr_rd_done <= 1'd0;
				end
			else if((state == STOP) && (cnt_i2c_clk == 2'd3))
				begin
					i2c_wr_rd_done <= 1'd1;
				end
			else
				begin
					i2c_wr_rd_done <= 1'd0;
				end
		end
	
	
endmodule
