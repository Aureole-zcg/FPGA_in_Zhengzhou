module div_8(
    input wire clk,rst_n,
    output reg clk_div8
);

reg [2:0] cnt ;

always @(negedge clk, negedge rst_n)
begin
    if (~rst_n)
        cnt<=3'd0;
    else 
	     cnt <= cnt+1'b1;//溢出清零
	     //if (cnt<=6)//常规判断清零
	     //       cnt<=cnt+1'd1;//0~7,8个上升沿一个周期，6.25MHz，八分频
        //else cnt<=1'd0;
end

always @(negedge clk, negedge rst_n) 
begin
    if (~rst_n)
        clk_div8<=1'd0;
    else
        begin     
		      case(cnt)
				3'd0,3'd1,3'd2,3'd3:clk_div8<=1'b0;//由于上降沿，右移一个时钟周期相位
                default :clk_div8<=1'b1 ;
            endcase
		  end
    
end
endmodule
