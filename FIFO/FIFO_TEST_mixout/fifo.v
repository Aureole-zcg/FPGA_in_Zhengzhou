module fifo
(
    input wire clk        ,
    input wire rst_n      ,
    input wire [15:0] data,
    input wire wrreq      ,

    output wire [15:0] q_fifo,
    output wire flag_fifo_rams1//用于传递信号,使fifo结束后，启动单通道ram，同步reque
);

wire [10:0] usedw;
wire        empty;
wire        full ;

reg rdreq     ;
//reg [15:0] data_in;

fifo_16x2048	fifo_16x2048_inst (
	.clock ( clk      ),
	.data  ( data     ),
	.rdreq ( rdreq    ),
	.wrreq ( wrreq    ),
	.empty ( empty    ),
	.full  ( full     ),
	.q     ( q_fifo   ),
	.usedw ( usedw    )
	);


reg [11:0] cnt_fifo;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        cnt_fifo <= 12'd0;
    else cnt_fifo <= cnt_fifo + 1'b1;//溢出清零
end
//
//always @(posedge clk, negedge rst_n) 
//begin
//    if (~rst_n)
//    begin
//        wrreq <= 1'b0;
//        data_in <= 16'd0;
//    end
//    else if (cnt_fifo<=12'd2047)
//    begin
//        wrreq <= 1'b1;
//        data_in <=data;
//    end
//    else begin
//        wrreq <= 1'b0;
//        data_in <= 16'd0;
//    end
//end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        rdreq <= 1'b0;
    else if (cnt_fifo>12'd2047)
        rdreq <= 1'b1;
    else 
        rdreq <= 1'b0;
end

//reg rdreq_D;
//always @(posedge clk, negedge rst_n)
//begin
//    if (~rst_n)
//        rdreq_D <= 1'b0;
//    else rdreq_D <= rdreq;
//end

assign flag_fifo_rams1 = rdreq;


endmodule
