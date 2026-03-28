module beep_adjustable_template
#(
    parameter Do = 190840,//七个基础音调，音调的频率转化为时钟周期个数
    parameter Re = 170068,
    parameter Mi = 151515,
    parameter Fa = 143266,
    parameter So = 127551,
    parameter La = 113636,
    parameter Si = 101214,
    parameter TIM = 25000000//0.5S//--------调整点1

)
(
    input wire clk, rst_n,

    output reg beep_out
);

reg [31:0] cnt_s, tone_cnt, tone;//计数0.5s（音调鸣响时长）//频率计数器，计数PWM低电平//具体音调
reg [31:0] tone_num;//音调数，第几个音调

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    cnt_s<=32'd0;
    else if (cnt_s==TIM-1)//每个音调响0.5s
        cnt_s<=1'd0;
        else cnt_s<=cnt_s+1'd1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_num<=32'd0;
    else if (tone_num==6 && cnt_s==TIM-1)//计数0~6，7个音调//--------调整点2
        tone_num<=32'd0;
        else if (cnt_s==TIM-1)
		      tone_num<=tone_num+1'd1;    
              else tone_num<=tone_num;//保持当前音调，直到0.5s计数结束
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone<=Do;
    else case(tone_num)//确定音调//--------调整点3
         3'd0:tone<=Do;
         3'd1:tone<=Re;
         3'd2:tone<=Mi;
         3'd3:tone<=Fa;
         3'd4:tone<=So;
         3'd5:tone<=La;
         default :tone<=Si;
         endcase   
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    tone_cnt<=32'd0;
    else if (tone_cnt==tone-1 || cnt_s==TIM-1)//或（tone_cnt > tone)
        tone_cnt<=32'd0;
        else tone_cnt<=tone_cnt+1'd1;//开始累计高电平时间计数，实现音调对应PWM波
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    beep_out<=1'b1;
    else if(tone_cnt<=tone>>1)//占空比50%//占空比越大声音越大//--------调整点4
        beep_out<=1'b0;
        else beep_out<=1'b1;
end

endmodule
