module ram_dbl_compare
(
    input wire clk,
    input wire rst_n,
    input wire [15:0] q_ram_s,
    input wire flag_rams1_ramdbl,//用于传递信号,使rams1结束后，启动双通道ram，同步wren

    output wire [15:0] q_ram_dbl,
    output wire flag_ramdbl_rden
);

reg [10:0] rdaddr, wraddr;
reg rden, wren;

ram_dbl_16x2048	ram_dbl_16x2048_inst2 (
	.clock     ( clk       ),
	.data      ( q_ram_s   ),
	.rdaddress ( rdaddr    ),
	.rden      ( rden      ),
	.wraddress ( wraddr    ),
	.wren      ( wren      ),
	.q         ( q_ram_dbl )
	);

reg flag_rams1_ramdbl_D;
always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
        flag_rams1_ramdbl_D <= 1'b0;
    else flag_rams1_ramdbl_D <= flag_rams1_ramdbl;
end

reg flag_dbl;
always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
        flag_dbl <= 1'b0;
    else if (flag_rams1_ramdbl_D && ~flag_rams1_ramdbl)
            flag_dbl <= 1'b1;
            else flag_dbl <= 1'b0;
end



reg [12:0] cnt;//0~4097

always @(posedge clk, negedge rst_n)
begin
    if (~rst_n)
    cnt <= 13'd0;
    else if (flag_dbl == 1'b1)
        cnt <= cnt + 1'b1;
        else if (cnt >13'd0 && cnt <13'd4097)
            cnt <= cnt + 1'b1;
            else cnt <= 13'd0;
end

//reg [15:0] data_in;

always @(posedge clk, negedge rst_n) //写入
begin
    if (~rst_n)
    begin
        wren   <= 1'b0;
        wraddr <= 10'b0;
        //data_in   <= 16'd0;
    end
    else if (flag_dbl == 1'b1 || cnt >= 13'd1 && cnt <= 13'd2047)//0~2047 wren拉高
        begin
            wren <= 1'b1;//写入
            wraddr <= cnt ;//0~2047
            //data_in <= q_ram_s;
        end
            else 
                begin
                    wren   <= 1'b0;
                    wraddr <= 10'b0;
                    //data_in   <= 16'd0;
                end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rden <= 1'b0;
    else if (cnt >= 13'd2049 && cnt <= 13'd4097)//2050~4097 rden拉高
        rden <= 1'b1;//读取
        else rden <= 1'b0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    rdaddr <= 9'b0;
    else if(rden)
        rdaddr <= rdaddr + 1'b1;//自加读取
        else rdaddr <= 9'b0;
end

assign flag_ramdbl_rden = rden;
endmodule
