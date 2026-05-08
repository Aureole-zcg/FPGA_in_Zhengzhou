//当FPGA作为SPI通讯的从机时的代码
module SPI_Slave(
    input               rst_n,      // 时钟及复位信号
    input               clk_200m,   // 时钟及复位信号
    input               cs,         // CS输入
    input               sclk,       // SCLK输入
    input               spi_di,     // DI输入
    input      [7:0]    send_data,  // 需要发送的数据
    input               send_flag,  // 发送标识，当为高电平时，发送数据
    output reg          spi_do,     // 数据输出DO
    output reg [7:0]    recv_data,  // 接收到的数据
    output reg          recv_done,  // 接收完成标识
    output reg          send_done   // 发送完成标识
);
 
reg  [3:0]  recv_sta;   // 接收过程状态字
reg  [3:0]  send_sta;   // 发送过程状态字
reg  [3:0]  recv_cnt;   // 接收bit计数
reg  [3:0]  send_cnt;   // 发送bit计数
reg  [7:0]  recv_tmp;   // 接收临时寄存器，接收完成后转存至recv_data
reg  [7:0]  send_tmp;   // 发送临时寄存器，
reg  [1:0]  cs_sync;    // cs状态捕捉
reg  [1:0]  sclk_sync;  // sclk状态捕捉
wire        cs_fal;     // cs下降沿
wire        sclk_ris;   // sclk上升沿
wire        sclk_fal;   // sclk下降沿
 
 
// ---- main code ----
assign cs_fal = cs_sync[1:0] == 2'b10;      // cs下降沿判断
assign sclk_ris = sclk_sync[1:0] == 2'b01; // sclk上升沿判断
assign sclk_fal = sclk_sync[1:0] == 2'b10; // sclk下降沿判断
// 边沿检测过程块，所有边沿检测均在此执行
always @(posedge clk_200m or negedge rst_n) begin
    if(!rst_n) begin
        cs_sync <= 2'b11;      //cs时钟空闲状态位高电平
        sclk_sync <= 2'b11;      //sclk时钟空闲状态位高电平,CPOL=1,CPHA=1
    end
    else begin
        cs_sync <= {cs_sync[0], cs};  //cs_sync[0] <= cs ;  cs_sync[1] <= cs_sync[0]  ;
        sclk_sync <= {sclk_sync[0], sclk};
    end
end
// 功能描述：SPI接收字节过程块，FPGA运行过程中，不停判断CS低电平,
//          若有数据传输，则接收，当接收满一个字节后置位接收完成标识.
always @(posedge clk_200m or negedge rst_n) begin
    if(!rst_n) begin
        recv_tmp <= 8'd0;
        recv_cnt <= 4'd0;
        recv_done <= 1'b0;
        recv_sta <= 4'd0;
    end
    else begin
        if (cs_fal) begin                   // CS下降沿
            recv_tmp <= 8'd0;
            recv_cnt <= 4'd0;
            recv_done <= 1'b0;
            recv_sta <= 4'd0;
        end
        else begin
            if (!cs) begin
                case (recv_sta)
                    4'd0: begin             // 接收数据准备
                        recv_tmp <= 8'd0;
                        recv_cnt <= 4'd0;
                        recv_done <= 1'b0;
                        recv_sta <= 4'd1;
                    end
                    4'd1: begin
                        if (sclk_ris) begin // sclk上升沿读取di，移位写入8bit数据
                            recv_tmp <= {recv_tmp[6:0], spi_di}; // 上升沿(第二个边沿开始)读数据，左移
                            if(recv_cnt == 4'd7) begin
                                recv_cnt <= 4'd0;
                                recv_sta <= 4'd2;
                            end
                            else begin
                                recv_cnt <= recv_cnt + 4'd1;
                            end
                        end
                    end
                    4'd2: begin
                        recv_data <= recv_tmp;      // 接收8 bits完成，数据转存至recv_data
                        recv_done <= 1'b1;          // 接收完成标识置1
                        recv_sta <= 4'd3;
                    end
                    4'd3: recv_sta <= 4'd0;         // 等待1个时钟
                    default: recv_sta <= 4'd0;
                endcase
            end // if (!cs) begin
        end
    end
end
// 功能描述：SPI字节发送过程块，当有数据需要发送时，外部模块置位send_flag
//          当检测到此标识时，发送send_data数据
always @(posedge clk_200m or negedge rst_n) begin
    if(!rst_n) begin
        send_cnt <= 4'd0;
        send_done <= 1'b0;
        send_tmp <= 8'd0;
        spi_do <= 1'b1;
        send_sta <= 4'd0;
    end
    else begin
        if (cs_fal) begin           // CS下降沿
            send_cnt <= 4'd0;
            send_done <= 1'b0;
            send_tmp <= 8'd0;
            spi_do <= 1'b1;
            send_sta <= 4'd0;
        end
        else begin
            if (!cs) begin
                case (send_sta)
                    4'd0: begin                     // 开始准备发送，等待发送标识控制高电平
                        if (send_flag) begin        // 等待发送标识
                            send_done <= 1'b0;
                            send_cnt <= 4'd0;
                            send_tmp <= send_data;  // 转送数据，避免其他模块改写导致数据变化
                            send_sta <= 4'd1;
                        end
                    end
                    4'd1: begin                     // 每一个sclk下降沿向spi_do写入一个bit
                        if (sclk_fal) begin         // 等待时钟下降沿
                            spi_do <= send_tmp[4'd7 - send_cnt];
                            if(send_cnt == 4'd7) begin
                                send_cnt <= 4'd0;
                                send_done <= 1'b1;
                                send_sta <= 4'd2;
                            end
                            else begin
                                send_cnt <= send_cnt + 4'd1;
                            end
                        end
                    end
                    4'd2: send_sta <= 4'd3;
                    4'd3: send_sta <= 4'd0;
                    default: send_sta <= 4'd0;
                endcase
            end //if (!cs) begin
        end
    end
end
endmodule
