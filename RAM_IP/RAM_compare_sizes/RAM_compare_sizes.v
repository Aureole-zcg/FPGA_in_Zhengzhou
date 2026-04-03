//调用双端口RAM,读写共用1个时钟，数据输入输出位宽相等，将RAM写满随机数，然后读出数据，找出最大值和地址

module RAM_compare_sizes
(
    input wire clk, wren,
    input wire [4:0] wraddr, 
	 input wire [3:0]data, 
    input wire rst_n,

    output reg  [3:0] q_MAX,
	output reg  [4:0] addr_MAX
);

reg [4:0] rdaddr;
reg rden;

wire [3:0] q;

ram4x32_4	ram4x32_4_inst (
   .clock     ( clk ),
	.data      ( data ),
	.rdaddress ( rdaddr ),
	.rden      ( rden ),
	.wraddress ( wraddr ),
	.wren      ( wren ),
	
	.q         ( q )
	);

reg wren_d;
reg wren_fall;

always @(posedge clk, negedge rst_n)
begin
	if (~rst_n)
	begin
		wren_d <= 1'b0;
		wren_fall <= 1'b0;
	end
	else
	begin
		wren_d <= wren;
		wren_fall <= wren_d & ~wren;//下降沿检测
	end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rden <= 1'b0;
    else if (wren_fall)//写入完成，开始读取
        rden <= 1'b1;//读取
        else if (rdaddr == 5'd31)//读取完成，停止读取 
		    rden <= 1'b0;
			else rden <= rden;//保持读使能状态
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rdaddr <= 10'd0;
    else begin
        if(rden)//写使能高电平
        rdaddr <= rdaddr + 1'b1;//地址递增
            else rdaddr <= 10'd0;
    end
end

reg rden_d;
reg rden_dd;
reg rden_fall;

always @(posedge clk, negedge rst_n)//读使能下降沿检测
begin
	if (~rst_n)
	begin
		rden_d <= 1'b0;
		rden_dd <= 1'b0;
		rden_fall <= 1'b0;
	end
	else
	begin
		rden_d <= rden;
		rden_dd <= rden_d;//延迟两个时钟周期，保持使能信号和数据同步
		rden_fall <= ~rden_d & rden_dd;//下降沿检测
	end
end

reg [4:0] rdaddr_D;
reg [4:0] rdaddr_DD;

always @(posedge clk, negedge rst_n)//读使能下降沿检测
begin
	if (~rst_n)
	begin
		rdaddr_D <= 5'b0;
		rdaddr_DD <= 5'b0;
	end
	else
	begin
		rdaddr_D <= rdaddr;
		rdaddr_DD <= rdaddr_D;//延迟两个时钟周期，保持地址和数据同步
	end
end

reg [3:0] q_MAX_reg;
reg [4:0] rdaddr_MAX_reg;

always @(posedge clk, negedge rst_n)
begin
	if (~rst_n)
	begin
		q_MAX_reg <= 4'b0;
        rdaddr_MAX_reg <= 5'b0;
	end
	else if (rdaddr_DD >= 1'b1 && q >= q_MAX_reg)//更新最大值和地址
	    begin
	    	q_MAX_reg <= q;
	    	rdaddr_MAX_reg <= rdaddr_DD;
	    end
		else begin
			    q_MAX_reg <= q_MAX_reg;
	    	    rdaddr_MAX_reg <= rdaddr_MAX_reg;
		end
end

always @(posedge clk, negedge rst_n)
begin
	if (~rst_n)
	begin
		q_MAX <= 4'b0;
        addr_MAX <= 5'b0;
	end
	else if (rden_fall)//读完成，输出最大值和地址
	    begin
	    	q_MAX <= q_MAX_reg;
	    	addr_MAX <= rdaddr_MAX_reg;
	    end
		else begin
			    q_MAX <= q_MAX;
	    	    addr_MAX <= addr_MAX;
		end
end
endmodule
