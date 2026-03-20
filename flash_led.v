//目标：LED0.5s交替亮灭
//使用EP4CE10F17C8，利用计数器和50MHz晶振，计数25000000个上升边沿
module flash_led
(
    input wire clk,
    input wire rst_n,

    output reg led
);

reg [31:0] cnt ;
always @(posedge clk , negedge rst_n)
begin
    if(~rst_n)
        cnt<=1'd0;
    else if(cnt<49999999)
        cnt<=cnt+1'd1;
    else cnt<=1'd0;
end 

always @(*) 
begin
    if (cnt<=24999999) 
        led=1'b0;
    else led=1'b1;
end
endmodule
