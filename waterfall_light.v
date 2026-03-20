//项目目标：4个LED实现流水灯（500ms流水）效果
module waterfall_light
(
    input wire clk,
    input rst_n,

    output reg led0,led1,led2,led3
);

reg [31:0] cnt;
reg [3:0] M;
parameter CNT_MAX = 25000000;//cnt计数25,000,000个上升沿

always@(posedge clk,negedge rst_n)
begin
    if(~rst_n)
        begin
            cnt<=1'd0;
            M<=4'b0111;//初始状态led0亮
        end
    else if(cnt<CNT_MAX-1)
            cnt<=cnt+1'd1;
        else 
            begin
                cnt<=1'd0;
                M<={M[2:0],M[3]};//循环移位  
            end 
end

always@(*)
begin
    led0={M[0]};
    led1={M[1]};
    led2={M[2]};
    led3={M[3]};
end

endmodule
