module fsm
  (
	input wire iic_clk,				//1MHz时钟
	input wire rst_n,
	input wire write_key,			//写按键 
	input wire read_key,			//读按键
	
	output reg wren,				//写使能
	output reg rden,				//读使能
	output reg i2c_start,			//开始标志信号
	output wire addr_num,			//字地址字节长度
	output wire [15:0] byte_addr,	//EEPROM字地址
	output wire [7:0] wr_data,		//写数据
	
	input wire i2c_wr_rd_done		//单次写/读完成
	);
	
	assign addr_num = 1'd1;
	assign byte_addr = 16'h0000;
	assign wr_data = 8'b1001_1010;
	
	
	
	//按键消抖
	parameter TIME_20MS = 16'd19_999;
	
	reg [15:0] write_key_cnt;
	reg [15:0] read_key_cnt;
	
	reg write_key_flag;
	reg read_key_flag;
	
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					write_key_cnt <= 16'd0;
				end
			else if(write_key)
				begin
					write_key_cnt <= 16'd0;
				end
			else if(write_key_cnt == TIME_20MS)
				begin
					write_key_cnt <= write_key_cnt;
				end
			else
				begin
					write_key_cnt <= write_key_cnt + 1'd1;
				end
		end
	
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					write_key_flag <= 1'd0;
				end
			else if(write_key_cnt == (TIME_20MS - 1'd1))
				begin
					write_key_flag <= 1'd1;
				end
			else
				begin
					write_key_flag <= 1'd0;
				end
		end
	
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					read_key_cnt <= 16'd0;
				end
			else if(read_key)
				begin
					read_key_cnt <= 16'd0;
				end
			else if(read_key_cnt == TIME_20MS)
				begin
					read_key_cnt <= read_key_cnt;
				end
			else
				begin
					read_key_cnt <= read_key_cnt + 1'd1;
				end
		end

	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					read_key_flag <= 1'd0;
				end
			else if(read_key_cnt == (TIME_20MS - 1'd1))
				begin
					read_key_flag <= 1'd1;
				end
			else
				begin
					read_key_flag <= 1'd0;
				end
		end
	
	//读写操作控制状态机
	parameter IDLE = 8'd0;
	parameter S0 = 8'd1;
	
	reg [7:0] state;
	
	always @ (posedge iic_clk or negedge rst_n)
		begin
			if(~rst_n)
				begin
					state <= IDLE;
					wren <= 1'd0;
					rden <= 1'd0;
					i2c_start <= 1'd0;
				end
			else case(state)
				IDLE:
					begin
						if(write_key_flag)		//写按键按下
							begin
								state <= S0;
								wren <= 1'd1;
								i2c_start <= 1'd1;
							end
						else if(read_key_flag)	//读按键按下
							begin
								state <= S0;
								rden <= 1'd1;
								i2c_start <= 1'd1;
							end
						else
							begin
								state <= IDLE;
								wren <= 1'd0;
								rden <= 1'd0;
								i2c_start <= 1'd0;
							end
					end
				S0:
					begin
						i2c_start <= 1'd0;
						
						if(i2c_wr_rd_done)
							begin
								state <= IDLE;
								wren <= 1'd0;
								rden <= 1'd0;
							end
						else
							begin
								state <= S0;
								wren <= wren;
								rden <= rden;
							end
					end
				default:
					begin
						state <= IDLE;
						wren <= 1'd0;
						rden <= 1'd0;
						i2c_start <= 1'd0;
					end
			endcase
		end

endmodule
