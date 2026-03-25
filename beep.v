module beep
#(
    parameter Do = 190840,//七个基础音调，音调的频率转化为时钟周期个数
    parameter Re = 170068,
    parameter Mi = 151515,
    parameter Fa = 143266,
    parameter So = 127551,
    parameter La = 113636,
    parameter Si = 101214,
    parameter TIM = 25000000//0.5S

)
(
    input wire clk, rst_n,

    output reg beep_out
);

reg [31:0] cnt_s, tone_cnt, tone;//计数0.5s//频率计数器，计数PWM低电平//具体音调
reg [2:0] tone_num;//音调数，第几个音调

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_s<=32'd0;
    else if (cnt_s==TIM-1)//0.5s
        cnt_s<=1'd0;
        else cnt_s<=cnt_s+1'd1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_num<=3'd0;
    else if (tone_num==6 && cnt_s==TIM-1)//计数0~6，7个音调
        tone_num<=3'd0;
        else if (cnt_s==TIM-1)
		      tone_num<=tone_num+1'd1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone<=Do;
    else case(tone_num)//确定音调
         0:tone<=Do;
         1:tone<=Re;
         2:tone<=Mi;
         3:tone<=Fa;
         4:tone<=So;
         5:tone<=La;
         default :tone<=Si;
         endcase   
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_cnt<=32'd0;
    else if (tone_cnt==tone-1 || cnt_s==TIM-1)
        tone_cnt<=32'd0;
        else tone_cnt<=tone_cnt+1'd1;//开始累计高电平时间计数，实现音调对应PWM波
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    beep_out<=1'b1;
    else if(tone_cnt<=tone>>1)//占空比50%
        beep_out<=1'b0;
        else beep_out<=1'b1;
end

endmodule
