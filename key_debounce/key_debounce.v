module key_debounce
#(
    parameter Debounce_TIME = 20_000_000//消抖信号20ms
)
(
    input wire key_in, clk, rst_n,

    output reg key_out
);
reg [31:0] cnt;//低电平计数器
localparam CNT_MAX = Debounce_TIME/20-1;//20ns时钟晶振

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt<=32'd0;
    else if (key_in==1'b1)
            cnt<=32'd0;
        else if (cnt==CNT_MAX)
                cnt<=cnt;
            else cnt<=cnt+1'b1;    
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        key_out<=1'b0;
    else if (cnt==CNT_MAX-1)//最后一位计数保持，以控制按下次数
            key_out<=1'b1;
        else key_out<=1'b0;
end
endmodule
