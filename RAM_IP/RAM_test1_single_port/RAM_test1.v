module RAM_test1
(
    input wire clk, rst_n, 
    output wire [15:0] q
);

reg wren;//读写使能，1写，0读
reg [15:0] addr;//地址
reg [15:0] data;//数据

ram_8x256	ram_8x256_inst (
	.address ( addr ),
	.clock ( clk ),
	.data ( data ),
	.wren ( wren ),
	.q ( q )
	);

reg [15:0] cnt;
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt <= 8'd0;
	 else if (cnt == 1999)
	     cnt <= 8'd0;
        else cnt <= cnt + 1'b1;
end

/*调用ram。实现连续写入1000个数据（1~1000），然后数据倒着读出来，即显示q的效果为1000~1*/

reg [15:0] cnt_extra;
always @ (posedge clk, negedge rst_n)
begin
    if (~rst_n)
	 cnt_extra <= 16'd0;
	 else if (cnt > 999)
	     cnt_extra <= cnt_extra +16'd2;
		  else if (cnt_extra == 1000)
		      cnt_extra <= 16'd0;
end 

always @(posedge clk, negedge rst_n) //正序写入，倒序地址输出
begin
    if (~rst_n)
	 begin
	     wren <= 1'b0;
        addr <= 8'd0;
        data <= 8'd0;
	 end
	 else if (cnt <= 999)
	     begin
		      wren <= 1'b1;//写入
				addr <= cnt;
				data <= cnt + 1'b1;
		  end 
		  else if (cnt > 999)
		  begin
		      wren <= 1'b0;//读取
				addr <= cnt-cnt_extra;
				data <= 8'd0;
		  end
end

/*
always @(posedge clk, negedge rst_n) //地址倒序写入
begin
    if (~rst_n)
	 begin
	     wren <= 1'b0;
        addr <= 8'd0;
        data <= 8'd0;
	 end
	 else if (cnt <= 999)
	     begin
		      wren <= 1'b1;//写入
				addr <= 999-cnt;
				data <= cnt + 1'b1;
		  end 
		  else if (cnt > 999)
		  begin
		      wren <= 1'b0;//读取
				addr <= cnt-1000;
				data <= 8'd0;
		  end
end
*/

/*
//RAM读写时序 单独写、读 连续写、读
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        wren <= 1'b0;
        addr <= 8'd0;
        data <= 8'd0;
    end
    else if (cnt == 8'd1)//单独写
        begin
            wren <= 1'b1;
            addr <= 8'd0;
            data <= 8'd11;
        end
        else if (cnt == 8'd3)
            begin
                wren <= 1'b1;
                addr <= 8'd1;
                data <= 8'd7;
            end
            else if (cnt >= 8'd10 && cnt <= 8'd19)//10~19 连续写
                begin
                    wren <= 1'b1;
                    addr <= cnt;
                    data <= cnt; 
                end
                else if (cnt == 8'd27)//单独读
                    begin
                        wren <= 1'b0;
                        addr <= 8'd1;
                        data <= 8'd0;//don't care date
                    end
                    else if (cnt >= 8'd31 && cnt <= 8'd37)
                        begin
                            wren <= 1'b0;
                            addr <= cnt - 8'd21;
                            data <= 8'd0;
                        end
                        else begin 
                            wren <= 1'b0;
                            addr <= 8'd0;
                            data <= 8'd0;
                        end
end
*/
endmodule
