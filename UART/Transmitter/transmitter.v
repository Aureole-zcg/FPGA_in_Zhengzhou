module transmitter
#(
    parameter SYS_CLK = 50_000_000,//50MHz
    parameter UART_BPS = 9600      //波特率
)
(
    input wire clk, rst_n, 

    output reg tx
);

localparam  Bound_MAX = SYS_CLK / UART_BPS;

wire [7:0] data;
wire data_flag;
data_genaration data_genaration_inst
(
    . clk  (clk  ), 
    . rst_n(rst_n),

   . data     (data     ),
   . data_flag(data_flag)
);

reg tx_en ;//tx使能信号
reg [15:0] baud_cnt;//每个码元长度最大值Bound_MAX
reg bit_flag;
reg [3:0] bit_cnt;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        tx_en <= 1'b0;
    else if (bit_flag == 1'b1 && bit_cnt == 4'd9)
            tx_en <= 1'b0;
        else if (data_flag)
                tx_en <= 1'b1;
            else tx_en <= tx_en;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        baud_cnt <= 16'd0;
    else if (tx_en == 1'b0 || baud_cnt == Bound_MAX - 1'b1)
            baud_cnt <= 16'd0;
        else if (tx_en == 1'b1)
                baud_cnt <= baud_cnt + 1'b1;
            else baud_cnt <= baud_cnt;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        bit_flag <= 1'b0;
    else if (baud_cnt == 1'b1)
            bit_flag <= 1'b1;
        else bit_flag <= 1'b0;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        bit_cnt <= 4'd0;
    else if (bit_cnt == 4'd9 && bit_flag == 1'b1)
            bit_cnt <= 4'd0;
        else if (bit_flag == 1'b1)
                bit_cnt <= bit_cnt + 1'b1;
            else bit_cnt <= bit_cnt;
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        tx <= 1'b1;
    else begin
        case (bit_cnt)
        0 : tx <= 1'b1;
        1 : tx <= 1'b0;//起始位
        2 : tx <= data[0];
        3 : tx <= data[1];
        4 : tx <= data[2];
        5 : tx <= data[3];
        6 : tx <= data[4];
        7 : tx <= data[5];
        8 : tx <= data[6];
        9 : tx <= data[7];
        default : tx <= 1'b1;//停止位和空闲状态
        endcase
    end    
end
endmodule
