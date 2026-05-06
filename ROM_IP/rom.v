module rom
(
    input wire clk, rst_n, 

    output wire [7:0] q
);

reg rden;
reg [11:0] addr;

rom8x256	rom8x256_inst (
	.address ( addr ),
	.clock   ( clk  ),
	.rden    ( rden ),
	.q       ( q    )
	);

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        rden <= 1'b0;
    else rden <= 1'b1;//一直读
end

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n)
        addr <= 12'd0;
    else addr <= addr + 1'b1;//溢出清零
end

endmodule
