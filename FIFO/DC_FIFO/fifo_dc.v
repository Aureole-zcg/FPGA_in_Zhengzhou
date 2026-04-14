module fifo_dc
(
    input wire wrclk,
               rdclk,
               rst_n,

    output wire [15:0] q
);

reg [7:0] data;//输入的8bit数据
reg wrreq, rdreq;//写请求，读请求
wire wrfull, wrempty, rdfull, rdempty;//写满，写空，读满，读空
wire [9:0] wrusedw;
wire [8:0] rdusedw;

fifo_8x1024_16	fifo_8x1024_16_inst (
	.data  ( data  ),
	.rdclk ( rdclk ),
	.rdreq ( rdreq ),
	.wrclk ( wrclk ),
	.wrreq ( wrreq ),

	.q       ( q       ),
	.rdempty ( rdempty ),
	.rdfull  ( rdfull  ),
	.rdusedw ( rdusedw ),
	.wrempty ( wrempty ),
	.wrfull  ( wrfull  ),
	.wrusedw ( wrusedw )
	);

reg [15:0] cnt;

always @(posedge wrclk, negedge rst_n) 
begin
    if (~rst_n)
        cnt <= 16'd0;
    else cnt <= cnt+ 1'b1;//溢满清零
end

always @(posedge wrclk, negedge rst_n) 
begin
    if (~rst_n)
        wrreq <= 1'b0;
    else if (cnt >= 16'd1 && cnt <= 16'd1024)
            wrreq <= 1'b1;
        else wrreq <= 1'b0;
end

always @(posedge wrclk, negedge rst_n) 
begin
    if (~rst_n)
        data <= 8'd0;
    else if (wrreq)
            data <= data +1'b1;
        else data <= data;
end

always @(posedge rdclk, negedge rst_n) 
begin
    if (~rst_n)
        rdreq <= 1'd0;
    else if (cnt >= 16'd1026 && cnt <= 16'd2049)
            rdreq <= 1'b1;
        else rdreq <= 1'd0;
end
endmodule
