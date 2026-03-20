//led低电平点亮，1s低电平，3s高电平
module flash_led1_3
#(//parameter全局变量定义参数
    parameter CNT1_MAX=16'd49999,//50000
    parameter CNT2_MAX=16'd4000// 50000*4000*20ns=4,000,000,000ns=4s
)
(
    input wire clk,
    input wire rst_n,

    output reg led
);

//localparam 局部变量
reg [15:0] cnt1 ;
reg [15:0] cnt2 ;

always @(posedge clk , negedge rst_n)
begin
    if(~rst_n)
        begin
            cnt1<=1'd0;
            cnt2<=1'd0;
        end    
    else 
        begin
            if(cnt1<CNT1_MAX)
                cnt1<=cnt1+1'd1;//0~49999
            else 
                begin
                    cnt1<=1'd0;
                    if(cnt2<CNT2_MAX-1)//0~3999
                    cnt2<=cnt2+1'd1;
                    else cnt2<=1'd0;
                end
        end
end 

always @(*) 
begin
    if (cnt2<=CNT2_MAX/4-1) 
        led=1'b0;//1s低电平,led亮
    else led=1'b1;//3s高电平,led灭
end
endmodule
