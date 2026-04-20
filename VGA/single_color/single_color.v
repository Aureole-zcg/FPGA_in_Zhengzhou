module single_color
(
    input wire clk, rst_n,

    output reg HSYNC, VSYNC,
    output reg [15:0] RGB565
);

wire c0, locked;
pll_25	pll_25_inst (
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
    else if (cnt_H == 10'd799)
            cnt_H <= 10'd0;
        else cnt_H <= cnt_H + 1'b1;
end

always @(posedge c0, negedge locked) 
begin
    if (~locked)
        cnt_V <= 10'd0;
    else if (cnt_V == 10'd524 && cnt_H == 10'd799)
            cnt_V <= 10'd0;
        else if (cnt_H == 10'd799)
                cnt_V <= cnt_V + 1'b1;
            else cnt_V <= cnt_V;
end

//HSYNC 同步96 后沿40 左边框8 有效图像640 右边框8 前沿8 行扫描周期800
always @(posedge c0, negedge locked) 
begin
    if (~locked)
        HSYNC <= 1'b0;
    else if (cnt_H >= 10'd0 && cnt_H <=95)
            HSYNC <= 1'b1;
        else HSYNC <= 1'b0;
end


always @(posedge c0, negedge locked) 
begin
    if (~locked)
        VSYNC <= 1'b0;
    else if (cnt_V >= 10'd0 && cnt_V <=1)
            VSYNC <= 1'b1;
        else VSYNC <= 1'b0;
end



// 有效图像区判断
wire valid_display;
assign valid_display = (cnt_H >= 144 && cnt_H < 784) && (cnt_V >= 35 && cnt_V < 515);

always @(posedge c0, negedge locked) begin
    if (~locked)
        RGB565 <= 16'b0;
    else if (valid_display)
        RGB565 <= 16'hffff;   // 白色
    else
        RGB565 <= 16'b0;      // 消隐期黑色
end

endmodule
