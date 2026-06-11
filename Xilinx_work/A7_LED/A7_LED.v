module A7_LED
#(
    parameter MAX_1S = 50_000_000, //50MHz T=20ns 50_000_000*20ns=1s
    parameter SIM_MAX_1S = 50 //for sim
)
(
    input wire clk,
    input wire rst_n,

    output reg  led0,
    output wire  led1,
    output wire  led2,
    output wire  led3
    
);
//assign  led1 =(~rst_n)? 1'b0:1'b1;
//assign  led2 = 1'b0;
//assign  led3 = 1'b0;
reg [25:0] cnt_1s;

always @(posedge clk, negedge rst_n) 
begin
    if (~rst_n) 
    begin
        cnt_1s <= 26'd0;
        led0 <= 1'b1;
    end 
    else 
    begin
        if (cnt_1s ==  MAX_1S - 1) 
            begin
                cnt_1s <= 26'd0;
                led0 <= ~led0; // Toggle LED state
            end 
         else 
         begin
            cnt_1s <= cnt_1s + 1'b1; // Increment counter
            led0 <= led0;
         end
      end
    end
    
endmodule
