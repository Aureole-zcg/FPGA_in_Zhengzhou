module ram_single
(
    input wire clk,
    input wire rst_n,
    input wire [15:0] q_fifo,
    input wire flag_fifo_rams1,//用于传递信号,使fifo结束后，启动单通道ram，同步reque

    output wire [15:0] q_ram_s,
    output wire flag_rams1_ramdbl
);

reg wren;
reg [10:0] addr;

ram_16x2048	ram_16x2048_inst (
	.address ( addr   ),
	.clock   ( clk    ),
	.data    ( q_fifo ),
	.wren    ( wren   ),
	.q       ( q_ram_s)
	);

reg [12:0] cnt_rams1;//0~4096
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_rams1 <= 12'd0;
	 else if (flag_fifo_rams1 == 1'b1)
	     cnt_rams1 <= cnt_rams1 + 1'b1;
        else if (cnt_rams1 >12'd2047 && cnt_rams1 < 12'd4095)
             cnt_rams1 <= cnt_rams1 + 1'b1;
            else cnt_rams1 <= 12'd0;
end

//reg [15:0] data_in;

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
	 begin
	    wren <= 1'b0;
        addr <= 11'd0;
	 end
	 else if (flag_fifo_rams1 == 1'b1)
	     begin
		      wren <= 1'b1;//写入
				addr <= cnt_rams1;
		  end 
		  else if (cnt_rams1 >= 12'd2048)
		  begin
		      wren <= 1'b0;//读出
				addr <= cnt_rams1-12'd2048;//改-2048√
		  end
end

assign flag_rams1_ramdbl = wren;

endmodule
