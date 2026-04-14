module fifo
(
    input wire clk, rst_n, wrreq, rdreq, 
    input wire [7:0] data,

    output wire [7:0] q
);



wire empty;//空
wire full;//满
wire [7:0] usedw;//用量

fifo_8x256	fifo_8x256_inst (
	.clock ( clk   ),
	.data  ( data  ),
	.rdreq ( rdreq ),
	.wrreq ( wrreq ),
	.empty ( empty ),
	.full  ( full  ),
	.q     ( q     ),
	.usedw ( usedw )
	);

endmodule
