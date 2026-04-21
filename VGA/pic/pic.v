module pic
#(
    parameter H_Scan                = 10'd800,//HSYNC扫描周期
    parameter V_Scan                = 10'd525,//VSYNC扫描周期
    parameter H_sync_cycle          = 10'd96 ,//HSYNC同步周期
    parameter V_sync_cycle          = 10'd2  ,//VSYNC同步周期
    parameter H_Adressable_Video_L  = 10'd144,//HSYNC有效图像区域周期最低值
    parameter H_Adressable_Video_M  = 10'd784,//HSYNC有效图像区域周期最高值
    parameter V_Adressable_Video_L  = 10'd35 ,//VSYNC有效图像区域周期最低值
    parameter V_Adressable_Video_M  = 10'd515,//VSYNC有效图像区域周期最高值
    parameter H_half_able           = 10'd464,//HSYNC有效图像区域周期的一半
    parameter V_half_able           = 10'd272,//VSYNC有效图像区域周期的一半
    parameter H_IMAGE               = 10'd114,//加载图像的行像素值
    parameter V_IMAGE               = 10'd79 //加载图像的场像素值
)
(
    input wire clk, rst_n,

    output reg HSYNC, VSYNC,
    output reg [15:0] RGB565
);

wire c0, locked;
clk_25	clk_25_inst (
	.areset ( ~rst_n ),
	.inclk0 ( clk ),
	.c0 ( c0 ),
	.locked ( locked )
	);

reg [9:0] cnt_H;
reg [9:0] cnt_V;

always @(posedge c0, negedge locked) 
begin
    if (~locked)
        cnt_H <= 10'd0;
    else if (cnt_H == H_Scan - 1'b1)//799
            cnt_H <= 10'd0;
        else cnt_H <= cnt_H + 1'b1;
end

always @(posedge c0, negedge locked) 
begin
    if (~locked)
        cnt_V <= 10'd0;
    else if (cnt_V == V_Scan - 1'b1 && cnt_H == H_Scan - 1'b1)
            cnt_V <= 10'd0;
        else if (cnt_H == H_Scan - 1'b1)
                cnt_V <= cnt_V + 1'b1;
            else cnt_V <= cnt_V;
end

//HSYNC 同步96 后沿40 左边框8 有效图像640 右边框8 前沿8 行扫描周期800
always @(posedge c0, negedge locked) 
begin
    if (~locked)
        HSYNC <= 1'b0;
    else if (cnt_H >= 10'd0 && cnt_H <= H_sync_cycle - 1'b1)//95
            HSYNC <= 1'b1;
        else HSYNC <= 1'b0;
end


always @(posedge c0, negedge locked) 
begin
    if (~locked)
        VSYNC <= 1'b0;
    else if (cnt_V >= 10'd0 && cnt_V <= V_sync_cycle - 1'b1)//1
            VSYNC <= 1'b1;
        else VSYNC <= 1'b0;
end

reg [13:0] address;
reg   rden;
wire [15:0]  q;
rom_16x16384	rom_16x16384_inst (
	.address ( address ),
	.clock ( c0 ),
	.rden ( rden ),
	.q ( q )
	);

// 有效图像区判断
wire valid_display;
assign valid_display = (cnt_H >= H_Adressable_Video_L && cnt_H < H_Adressable_Video_M) 
                       && (cnt_V >= V_Adressable_Video_L && cnt_V < V_Adressable_Video_M);


//ROM使能
//行同步信号有效图像周期（最小值/最大值） ± 有效图像值/2 - 加载图像像素行/2
always @(posedge c0, negedge locked) begin
    if (~locked)
        rden <= 1'b0;
    else if (valid_display)
        begin
            if (cnt_H >=  H_half_able - H_IMAGE /2 - 10'd2 
            && cnt_H <  H_half_able + H_IMAGE /2 - 10'd2
            && cnt_V >=  V_half_able - V_IMAGE /2 
            && cnt_V <  V_half_able + V_IMAGE /2)//
                rden <= 1'b1;
            else rden <= 1'b0;
        end
        else rden <= 1'b0;
end

always @(posedge c0, negedge locked) begin
    if (~locked)
        address <= 14'd0;
    else if (valid_display)
        begin
            if (rden == 1'b1)
                address <= address + 1'b1;
            else if (cnt_V >= V_Adressable_Video_M - 1'b1)
                    address <= 14'd0;
                else address <= address ;
        end
        else address <= address;
end



always @(posedge c0, negedge locked) begin
    if (~locked)
        RGB565 <= 16'b0;
    else if (valid_display)
        begin
            if (cnt_H >=  H_half_able - H_IMAGE /2 
            && cnt_H <  H_half_able + H_IMAGE /2 
            && cnt_V >=  V_half_able - V_IMAGE /2 
            && cnt_V <  V_half_able + V_IMAGE /2)
                RGB565 <= q;
            else begin
             if (cnt_H >= 144 && cnt_H <= 303)
                RGB565 <= 16'b10000_000000_00000;   
                else if (cnt_H >= 304 && cnt_H <= 463)
                    RGB565 <= 16'b01000_000000_00000; 
                    else if (cnt_H >= 464 && cnt_H <= 623)
                        RGB565 <= 16'b00100_000000_00000; 
                        else if (cnt_H >= 624 && cnt_H <= 783)
                            RGB565 <= 16'b00010_000000_00000; 
            end
        end
        else RGB565 <= 16'b0;
end

endmodule
