module test_fifo
(
    input wire wrclk,
               rdclk,
               rst_n,
               rdreq,

    output wire [63:0] q,
    output wire [12:0] rdusedw
);

reg [31:0] data;//输入的32bit数据
reg wrreq;//写请求，读请求
wire wrfull, wrempty, rdfull, rdempty;//写满，写空，读满，读空
wire [13:0] wrusedw;

fifo_32IN_64OUT_16384	fifo_32IN_64OUT_16384_inst (
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

reg [15:0] cnt;//0~65535

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
    else if (cnt >= 16'd1 && cnt <= 16'd16384)
            wrreq <= 1'b1;
        else wrreq <= 1'b0;
end

always @(posedge wrclk, negedge rst_n) 
begin
    if (~rst_n)
        data <= 32'd0;
    else if (wrreq)
            data <= data +1'b1;
        else data <= data;
end

//always @(posedge wrclk, negedge rst_n) 
//begin
//    if (~rst_n)
//        rdreq <= 1'd0;
//    else if (cnt >= 16'd16384 && cnt <= 16'd32768)//16385~32768
//            rdreq <= 1'b1;
//        else rdreq <= 1'd0;
//end
endmodule
