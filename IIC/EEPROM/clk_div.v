module clk_div(

	input wire sys_clk,		//50MHz系统时钟
	input wire sys_rst_n,	//复位信号，低电平有效
	
	output reg iic_clk,		//1MHz时钟，用于生成IIC时序
	output reg rst_n		//手写复位信号

);
	
	reg [7:0] cnt;	//循环计数0~24，用于50分频
	reg [7:0] cnt_reset;	//用于手写复位
	
	always @ (posedge sys_clk or negedge sys_rst_n)
		begin
			if(~sys_rst_n)
				begin
					cnt <= 8'd0;
				end
			else if(cnt == 8'd24)
				begin
					cnt <= 8'd0;
				end
			else
				begin
					cnt <= cnt + 1'd1;
				end
		end
	
	//50分频得到iic_clk
	always @ (posedge sys_clk or negedge sys_rst_n)
		begin
			if(~sys_rst_n)
				begin
					iic_clk <= 1'd0;
				end
			else if(cnt == 8'd24)
				begin
					iic_clk <= ~iic_clk;
				end
			else
				begin
					iic_clk <= iic_clk;
				end
		end
	
	//手写复位信号
	always @ (posedge sys_clk or negedge sys_rst_n)
		begin
			if(~sys_rst_n)
				begin
					cnt_reset <= 8'd0;
					rst_n <= 1'd0;
				end
			else if(cnt_reset == 8'd213)
				begin
					cnt_reset <= cnt_reset;
					rst_n <= 1'd1;
				end
			else
				begin
					cnt_reset <= cnt_reset + 1'd1;
					rst_n <= 1'd0;
				end
		end


endmodule
