//SPI循环发送
module data_ctrl
#(
    parameter MAX_1S = 10_000_000//10MHz T=100ns 1ms=10_000T//上电等待
)
(
    input wire clk_10MHz,rst_n,//T=100ns
    input wire flag_done,

    output reg [23:0] data,
    output reg spi_en,
    output wire [7:0] data_width,
    output wire [1:0] spi_cmd,
    output reg data_done//配置寄存器数据发送完毕标志位
);

assign data_width = 8'd24;
assign spi_cmd = 2'b00;

reg [15:0] cnt_1s;
reg [7:0] index;//数据号
wire [23:0] spi_wrdata;//数据值

hmc_7044_cfg_data hmc_7044_cfg_data_inst
(
	. index(index),

	. spi_wrdata(spi_wrdata)
);

always @(posedge clk_10MHz, negedge rst_n) 
begin
    if (~rst_n)
        cnt_1s <= 16'd0;
    else if (cnt_1s < MAX_1S)
            cnt_1s <= cnt_1s +1'b1;
            else cnt_1s <= cnt_1s;
end

always @(posedge clk_10MHz, negedge rst_n) 
begin
    if (~rst_n)
    begin
        data <= 24'd0;
        index <= 8'd0;
        spi_en <= 1'b0;
        data_done <= 1'b0;
    end
    else if (index == 8'd153 && flag_done == 1'b1)
            //index <= 8'd0;//循环发送
            begin//发完即止
                data <=24'd0;
                spi_en <= 1'b0;//关闭使能
                index <= index;
                data_done <= 1'b1;
            end
        else if (flag_done == 1'b1)
            begin
                data <= spi_wrdata;//发送数据
                spi_en <= 1'b1;//开启使能
                index <= index + 1'b1;//递增序号
            end
            else if (cnt_1s == MAX_1S - 1'b1)
                begin
                    data <= spi_wrdata;//发送数据
                    spi_en <= 1'b1;//开启使能
                    index <= index + 1'b1;//递增序号
                end
                else begin
                    data <= data;
                    spi_en <= 1'b0;//关闭使能
                    index <= index;
                    data_done <= 1'b0;
                end
end




endmodule
