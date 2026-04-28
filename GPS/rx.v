//接收来自上位机或者GPS通过串口发送的1bit信号
module rx
#(
    parameter SYS_CLK = 50_000_000,//50MHz
    parameter UART_BPS = 9600      //波特率
)
(
    input wire rx, clk, rst_n,

    output reg [7:0] out_data,
    output reg       out_flag
);

localparam  Bound_MAX = (SYS_CLK / UART_BPS)- 1'b1;//baud_cnt计数最大值

//rx过D触发器，二级稳定99%，第三级用于边沿检测

reg rx_D, rx_D2, rx_D3;//打拍
reg        valid_flag;//下降沿检测，触发使能
reg        work_en;//工作使能，下降沿检测标志位启动，bit标志位&&bit计数器停止
reg [15:0] baud_cnt;//码元计数器，计数到最大值接收一个码元
reg        bit_flag;//bit标志位
reg [3:0]  bit_cnt;//bit位计数器
reg [7:0]  out_data_r;//读取数据寄存器
reg        out_flag_r;//读取结束标志寄存器

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        rx_D  <= 1'b1;//空闲为高电平
        rx_D2 <= 1'b1;//空闲为高电平
        rx_D3 <= 1'b1;//空闲为高电平
    end
    else begin
        rx_D  <= rx;
        rx_D2 <= rx_D;
        rx_D3 <= rx_D2;
    end
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        valid_flag <= 1'b0;//标志位
    else if (rx_D3 && ~rx_D2)
            valid_flag <= 1'b1;//标志位触发
        else valid_flag <= 1'b0;//标志位归零
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        work_en <= 1'b0;//使能
    else if (bit_flag == 1'b1 && bit_cnt == 4'd8)
            work_en <= 1'b0;//使能停止
        else if (valid_flag == 1'b1)//标志位触发
                work_en <= 1'b1;//启动
            else work_en <= work_en;//维持启动或停止
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        baud_cnt <= 16'd0;//counter
    else if (work_en == 1'b0 || baud_cnt == Bound_MAX)//使能关闭 || 计满清零
            baud_cnt <= 16'd0;//counter清零
        else if (work_en == 1'b1)//使能开启时
                baud_cnt <= baud_cnt + 1'b1;//counter++
        else baud_cnt <= 16'd0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        bit_flag <= 1'b0;//标志位
    else if (baud_cnt == Bound_MAX/2'd2)//采样在数据中间值
            bit_flag <= 1'b1;//标志位触发
        else bit_flag <= 1'b0;//标志位归零
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        bit_cnt <= 4'd0;//bit位计数器
    else if (bit_flag == 1'b1 && bit_cnt == 4'd8)//读取完rx_D3
            bit_cnt <= 4'd0;
        else if (bit_flag == 1'b1)//标志位触发
                bit_cnt <= bit_cnt + 1'b1;//counter++
            else bit_cnt <= bit_cnt;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        out_data_r <= 8'd0;//读取数据寄存器
    else if (bit_flag == 1'b1 && bit_cnt >= 1'b1)//跳过起始位采集数据
            out_data_r <= {rx_D3,out_data_r[7:1]};//低位先进，向右移位
        else out_data_r <= out_data_r;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        out_flag_r <= 1'b0;//读取结束标志寄存器
    else if (bit_flag == 1'b1 && bit_cnt == 4'd8)//读取完rx_D3
            out_flag_r <= 1'b1;//读取结束标志拉高
        else out_flag_r <= 1'b0;
end

//全部读取结束，输出数据
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        out_data <= 8'd0;
        out_flag <= 1'b0;
    end
    else if (out_flag_r == 1'b1)//读取结束
        begin
            out_data <= out_data_r;//输出数据
            out_flag <= out_flag_r;//拉高读取结束标志
        end
        else begin
            out_data <= out_data;
            out_flag <= 1'b0;//标志拉低
        end
end

endmodule
