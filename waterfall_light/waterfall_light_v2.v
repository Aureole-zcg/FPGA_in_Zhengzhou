//项目目标：4个LED实现流水灯（500ms流水）效果,version2
module waterfall_light_v2
(
    input wire clk,
    input rst_n,

    output reg led0,led1,led2,led3
);

reg [31:0] cnt;
parameter CNT_MAX = 100_000_000;//cnt计数25,000,000个上升沿

always@(posedge clk,negedge rst_n)
begin
    if(~rst_n)
        begin
            cnt<=1'd0;
        end
    else if(cnt==CNT_MAX-1)
            cnt<=1'd0;
        else if (cnt<=CNT_MAX/4-1)
            begin
                led0<=1'b0;
                led1<=1'b1;
                led2<=1'b1;
                led3<=1'b1;
                cnt<=cnt+1'd1;
            end
            else if (cnt>CNT_MAX/4-1 && cnt<=CNT_MAX/2-1)
                begin
                    led0<=1'b1;
                    led1<=1'b0;
                    led2<=1'b1;
                    led3<=1'b1;
                    cnt<=cnt+1'd1;
                end
                else if (cnt>CNT_MAX/2-1 && cnt<=CNT_MAX/4*3-1)
                    begin
                        led0<=1'b1;
                        led1<=1'b1;
                        led2<=1'b0;
                        led3<=1'b1;
                        cnt<=cnt+1'd1;
                    end
                    else begin
                            led0<=1'b1;
                            led1<=1'b1;
                            led2<=1'b1;
                            led3<=1'b0;
                            cnt<=cnt+1'd1;
                        end
end
endmodule
