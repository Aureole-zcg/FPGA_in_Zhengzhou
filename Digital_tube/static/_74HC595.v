module _74HC595
(
    input wire clk, rst_n,
    input wire [5:0] sel,
    input wire [7:0] seg,

    output reg stcp, shcp, ds, oe_n//储存寄存器时钟，移位寄存器时钟，串行数据，输出使能
);

reg [1:0] cnt;//四分频时钟计数器

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 2'd0;
    else if (cnt == 2'd3)
            cnt <= 2'd0;
        else cnt <= cnt + 1'b1;
end

reg [3:0] data_cnt;//计数串行数据传输位

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        data_cnt <= 4'd0;
    else if (cnt == 2'd3 && data_cnt == 4'd13)
            data_cnt <= 4'd0;
        else if (cnt == 2'd3)
                data_cnt <= data_cnt + 1'b1;
            else data_cnt <= data_cnt;
end

wire [13:0] data;//数码管传输总数据数组

assign data = {seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel};

//移位寄存器时钟信号
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        shcp <= 1'b0;
    else if (cnt >= 2'd2)
            shcp <= 1'b1;
            else if (cnt >= 2'd0)
                shcp <= 1'b0;
                else shcp <= shcp;
end

//储存寄存器时钟信号
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        stcp <= 1'b0;
    else if (data_cnt == 4'd13 && cnt == 2'd3)
            stcp <= 1'b1;
        else stcp <= 1'b0;
end

//输出使能拉低
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        oe_n <= 1'b1;
    else oe_n <= 1'b0;
end

//传输串行数据，在ds数据的中间状态拉高产生上升沿，这样可以使shcp采得的ds数据更加稳定
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        ds <= 1'b0;
    else if (cnt == 2'd0)
            ds <= data[data_cnt];
        else ds <= ds;
end

endmodule