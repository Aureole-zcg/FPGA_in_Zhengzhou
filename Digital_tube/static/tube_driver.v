module tube_driver
#(
    parameter MAX_1s = 100_000_000,//1s

    parameter SEG_0 = 8'b1100_0000,
    parameter SEG_1 = 8'b1111_1001,
    parameter SEG_2 = 8'b1010_0100,
    parameter SEG_3 = 8'b1011_0000,
    parameter SEG_4 = 8'b1001_1001,
    parameter SEG_5 = 8'b1001_0010,
    parameter SEG_6 = 8'b1000_0010,
    parameter SEG_7 = 8'b1111_1000,
    parameter SEG_8 = 8'b1000_0000,
    parameter SEG_9 = 8'b1001_0000,
    parameter SEG_a = 8'b1000_1000,
    parameter SEG_b = 8'b1000_0011,
    parameter SEG_c = 8'b1100_0110,
    parameter SEG_d = 8'b1010_0001,
    parameter SEG_e = 8'b1000_0110,
    parameter SEG_f = 8'b1000_1110
)
(
    input wire clk, rst_n,

    output reg [5:0] sel,//select位选信号
    output reg [7:0] seg//segment段选信号
);

reg [31:0] cnt;//0.5s切换数码管显示

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 32'd0;
    else if (cnt == MAX_1s-1)
            cnt <= 32'd0;
        else cnt <= cnt + 1'b1;
end

reg add_flag;//数码管显示数字增加标志

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        add_flag <= 1'b0;
    else if (cnt == MAX_1s-1)
            add_flag <= 1'b1;
        else add_flag <= 1'b0;
end

reg [3:0] num;//数码管显示数字号0~f

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        num <= 4'h0;
    else if (add_flag == 1'b1)
            num <= num + 1'b1;
        else num <= num;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        sel <= 6'd0;//复位时位选关闭，工作时数码管全亮
    else sel <= 6'b000_001;
end

//num改变数码管显示
always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        seg <= 8'd0;
    else case (num)
        4'h0 : seg <= SEG_0;
        4'h1 : seg <= SEG_1;
        4'h2 : seg <= SEG_2;
        4'h3 : seg <= SEG_3;
        4'h4 : seg <= SEG_4;
        4'h5 : seg <= SEG_5;
        4'h6 : seg <= SEG_6;
        4'h7 : seg <= SEG_7;
        4'h8 : seg <= SEG_8;
        4'h9 : seg <= SEG_9;
        4'ha : seg <= SEG_a;
        4'hb : seg <= SEG_b;
        4'hc : seg <= SEG_c;
        4'hd : seg <= SEG_d;
        4'he : seg <= SEG_e;
        4'hf : seg <= SEG_f;
        default : seg <= SEG_0;
        endcase
end
endmodule
