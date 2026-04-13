fifo_16x2048	fifo_16x2048_inst (
	.clock ( clock_sig ),
	.data ( data_sig ),
	.rdreq ( rdreq_sig ),
	.wrreq ( wrreq_sig ),
	.empty ( empty_sig ),
	.full ( full_sig ),
	.q ( q_sig ),
	.usedw ( usedw_sig )
	);
