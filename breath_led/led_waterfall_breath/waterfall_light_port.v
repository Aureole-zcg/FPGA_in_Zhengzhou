//项目目标：4个LED实现流水呼吸灯（2s流水）效果，接口用于搭配breath_led
module waterfall_light_port
(
    input wire clk,
    input rst_n,
    input led_in0, led_in1, led_in2, led_in3, 

    output reg led0,led1,led2,led3
);

reg [31:0] cnt;
parameter CNT_MAX = 400_000_000;//cnt计数400，000，000个上升沿

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
                led0<=led_in0;
                led1<=1'b1;
                led2<=1'b1;
                led3<=1'b1;
                cnt<=cnt+1'd1;
            end
            else if (cnt>CNT_MAX/4-1 && cnt<=CNT_MAX/2-1)
                begin
                    led0<=1'b1;
                    led1<=led_in1;
                    led2<=1'b1;
                    led3<=1'b1;
                    cnt<=cnt+1'd1;
                end
                else if (cnt>CNT_MAX/2-1 && cnt<=CNT_MAX/4*3-1)
                    begin
                        led0<=1'b1;
                        led1<=1'b1;
                        led2<=led_in2;
                        led3<=1'b1;
                        cnt<=cnt+1'd1;
                    end
                    else begin
                            led0<=1'b1;
                            led1<=1'b1;
                            led2<=1'b1;
                            led3<=led_in3;
                            cnt<=cnt+1'd1;
                        end
end
endmodule
