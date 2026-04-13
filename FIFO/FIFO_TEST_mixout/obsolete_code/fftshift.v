module fftshift
(
    input wire clk,
    input wire rst_n,
    input wire [15:0] data_ram_in,
    input wire flag_ramdbl_rden,

    output reg [15:0] q_fft 
);

reg [11:0] cnt_add;//0~2048

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_add <= 12'd0;
    else if (flag_ramdbl_rden)
        cnt_add <= cnt_add +1'b1; //1~2048
        else cnt_add <= 12'd0;
end

reg [15:0] q_fft_r [2047: 0];

always @(posedge clk, negedge rst_n) //正序寄存
begin
    if (~rst_n)
        q_fft_r[cnt_add-1] <= 16'd0;
    else if (cnt_add >= 1'b1)
        q_fft_r[cnt_add-1] <= data_ram_in;
end

reg flag_ramdbl_rden_D;
reg flag_ramdbl_rden_DD;
reg flag_ramdbl_rden_fall;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
    begin
        flag_ramdbl_rden_D <= 1'b0;
        flag_ramdbl_rden_DD <= 1'b0;
        flag_ramdbl_rden_fall <= 1'b0;
    end
    else begin
        flag_ramdbl_rden_D <= flag_ramdbl_rden;
        flag_ramdbl_rden_DD <= flag_ramdbl_rden_D;
		  flag_ramdbl_rden_fall <= flag_ramdbl_rden_DD && ~flag_ramdbl_rden_D;
    end
end

reg [10:0] cnt_fftshift;//0~2047

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_fftshift <= 11'd1023;
    else if (flag_ramdbl_rden)
        cnt_fftshift <= cnt_fftshift +1'b1; //1024~2047
        else if (cnt_fftshift >11'd1023 && cnt_fftshift < 11'd2047)
             cnt_fftshift <= cnt_fftshift +1'b1;
            else if (cnt_fftshift == 11'd2047)
                cnt_fftshift <= 11'd0;
                else if (cnt_fftshift < 11'd1022)
                    cnt_fftshift <= cnt_fftshift +1'b1;
                    else cnt_fftshift <= 11'd1023;
end

//always @(posedge clk, negedge rst_n) //fftshift读取
//begin
//    if (~rst_n)
//        q_fft <= 16'd0;
//    else if (flag_ramdbl_rden_fall || cnt_fftshift <= 11'd2047)
//        q_fft <= q_fft_r[cnt_fftshift];
//        else q_fft <= q_fft;
//end

reg [10:0] cnt_fftshift_r;

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        q_fft <= 16'd0;
        cnt_fftshift_r <= 11'd0;
    end
    else if (flag_ramdbl_rden_fall || cnt_fftshift <= 11'd2046) begin
        // 在第1拍，寄存读取地址和读取操作
        cnt_fftshift_r <= cnt_fftshift;
        // 在第2拍，RAM输出数据，此时将数据寄存输出
        q_fft <= q_fft_r[cnt_fftshift_r];
    end
    else begin
        q_fft <= q_fft;
    end
end
endmodule
