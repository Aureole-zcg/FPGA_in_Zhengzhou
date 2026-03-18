module key_led_2to1
(
    input wire [3:0]key,

    output reg [1:0]led
);

//assign led=key;

//assign led[0]=key[0];
//assign led[1]=key[1];
//assign led[2]=key[2];
//assign led[3]=key[3];

//always
always @(*)
begin
    //ley=key;

     led[0]=key[0]|key[1];
     led[1]=key[2]|key[3];

end


endmodule
