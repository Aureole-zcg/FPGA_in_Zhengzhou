`timescale 1ns/1ps

module top_tb();


reg clk	 ;//系统时钟，频率50MHz
reg rst_n;//复位信号，低电平有效


//初始化系统时钟、全局复位
initial begin 
	clk = 1'b0;
	rst_n = 1'b0;
	#400
	rst_n = 1'b1;

end 

//clk:每 10ns 电平翻转一次，产生一个 50MHz 的时钟信号
always #10 clk = ~clk;


wire [7:0] mem[199:0];	//数组存储模拟出来的所有GPS数据
reg rx;				//单个GPS并行数据值  //rx

//将“”内部数据的ASCII码值赋值给对应寄存器
assign mem[0] = "$";//开始第一包数据
assign mem[1] = "G";
assign mem[2] = "P";//P
assign mem[3] = "R";
assign mem[4] = "M";
assign mem[5] = "C";
assign mem[6] = ",";//时间信息112233 北京时间192233
assign mem[7] = "1";
assign mem[8] = "1";
assign mem[9] = "2";

assign mem[10] = "2";
assign mem[11] = "3";
assign mem[12] = "3";
assign mem[13] = ".";
assign mem[14] = "0";
assign mem[15] = "0";
assign mem[16] = ",";
assign mem[17] = "A";//定位成功
assign mem[18] = ",";
assign mem[19] = "3";

assign mem[20] = "4";
assign mem[21] = "4";
assign mem[22] = "7";
assign mem[23] = ".";
assign mem[24] = "1";
assign mem[25] = "4";
assign mem[26] = "3";
assign mem[27] = "9";
assign mem[28] = "7";
assign mem[29] = ",";

assign mem[30] = "N";
assign mem[31] = ",";
assign mem[32] = "1";
assign mem[33] = "1";
assign mem[34] = "3";
assign mem[35] = "3";
assign mem[36] = "2";
assign mem[37] = ".";
assign mem[38] = "0";
assign mem[39] = "0";

assign mem[40] = "2";
assign mem[41] = "6";
assign mem[42] = "1";
assign mem[43] = ",";
assign mem[44] = "E";
assign mem[45] = ",";
assign mem[46] = "0";
assign mem[47] = ".";
assign mem[48] = "8";
assign mem[49] = "7";

assign mem[50] = "8";
assign mem[51] = ",";
assign mem[52] = ",";
assign mem[53] = "1";
assign mem[54] = "9";
assign mem[55] = "0";
assign mem[56] = "8";
assign mem[57] = "2";
assign mem[58] = "4";
assign mem[59] = ",";

assign mem[60] = ",";
assign mem[61] = ",";
assign mem[62] = "A";
assign mem[63] = "*";
assign mem[64] = "A";//校验值1
assign mem[65] = "A";//校验值2///////结束
assign mem[66] = "$";
assign mem[67] = "$";
assign mem[68] = "$";
assign mem[69] = "$";

assign mem[70] = "$";
assign mem[71] = "$";
assign mem[72] = "$";
assign mem[73] = "$";
assign mem[74] = "$";
assign mem[75] = "$";
assign mem[76] = "$";
assign mem[77] = "$";
assign mem[78] = "$";
assign mem[79] = "$";

assign mem[80] = "$";
assign mem[81] = "$";
assign mem[82] = "$";
assign mem[83] = "$";
assign mem[84] = "$";
assign mem[85] = "$";
assign mem[86] = "$";
assign mem[87] = "$";
assign mem[88] = "$";
assign mem[89] = "$";

assign mem[90] = "$";
assign mem[91] = "$";
assign mem[92] = "$";
assign mem[93] = "$";
assign mem[94] = "$";
assign mem[95] = "$";
assign mem[96] = "$";
assign mem[97] = "$";
assign mem[98] = "$";
assign mem[99] = "0";

assign mem[100] = "$";//开始
assign mem[101] = "G";
assign mem[102] = "P";//P
assign mem[103] = "R";
assign mem[104] = "M";
assign mem[105] = "C";
assign mem[106] = ",";
assign mem[107] = "1";//时间信息123456 北京时间203456
assign mem[108] = "2";
assign mem[109] = "3";

assign mem[110] = "4";
assign mem[111] = "5";
assign mem[112] = "6";
assign mem[113] = ".";
assign mem[114] = "0";
assign mem[115] = "0";
assign mem[116] = ",";
assign mem[117] = "A";//定位成功
assign mem[118] = ",";
assign mem[119] = "3";

assign mem[120] = "4";
assign mem[121] = "4";
assign mem[122] = "7";
assign mem[123] = ".";
assign mem[124] = "1";
assign mem[125] = "4";
assign mem[126] = "3";
assign mem[127] = "9";
assign mem[128] = "7";
assign mem[129] = ",";
                    
assign mem[130] = "N";
assign mem[131] = ",";
assign mem[132] = "1";
assign mem[133] = "1";
assign mem[134] = "3";
assign mem[135] = "3";
assign mem[136] = "2";
assign mem[137] = ".";
assign mem[138] = "0";
assign mem[139] = "0";
                    
assign mem[140] = "2";
assign mem[141] = "6";
assign mem[142] = "1";
assign mem[143] = ",";
assign mem[144] = "E";
assign mem[145] = ",";
assign mem[146] = "0";
assign mem[147] = ".";
assign mem[148] = "8";
assign mem[149] = "7";
                    
assign mem[150] = "8";
assign mem[151] = ",";
assign mem[152] = ",";
assign mem[153] = "1";
assign mem[154] = "9";
assign mem[155] = "0";
assign mem[156] = "8";
assign mem[157] = "2";
assign mem[158] = "4";
assign mem[159] = ",";
                    
assign mem[160] = ",";
assign mem[161] = ",";
assign mem[162] = "A";
assign mem[163] = "*";
assign mem[164] = "7";//校验值1
assign mem[165] = "D";//校验值2///////结束
assign mem[166] = "$";
assign mem[167] = "$";
assign mem[168] = "$";
assign mem[169] = "$";

assign mem[170] = "$";
assign mem[171] = "$";
assign mem[172] = "$";
assign mem[173] = "$";
assign mem[174] = "$";
assign mem[175] = "$";
assign mem[176] = "$";
assign mem[177] = "$";
assign mem[178] = "$";
assign mem[179] = "$";

assign mem[180] = "$";
assign mem[181] = "$";
assign mem[182] = "$";
assign mem[183] = "$";
assign mem[184] = "$";
assign mem[185] = "$";
assign mem[186] = "$";
assign mem[187] = "$";
assign mem[188] = "$";
assign mem[189] = "$";

assign mem[190] = "$";
assign mem[191] = "$";
assign mem[192] = "$";
assign mem[193] = "$";
assign mem[194] = "$";
assign mem[195] = "$";
assign mem[196] = "$";
assign mem[197] = "$";
assign mem[198] = "$";
assign mem[199] = "0";


//调用任务top_2
initial
begin
	rx <= 1;
	#1000;
	top_2();
	top_2();
	top_2();
end 

//创建任务top_2，本次任务调用 top_1 任务200次，发送 200 次数据，分别对应 mem[0：199]的值
task	top_2();
	integer	j;
	for(j=0;j<=199;j=j+1)	//调用 top_1 任务200次
		top_1(mem[j]);	
endtask


//创建任务 top_1，每次发送的数据有 10 位，依次将一位mem[j]的值传递进来冰转为串口帧结构
task	top_1(
	input	[7:0]top
);
	integer	i;
	for(i=0;i<10;i=i+1)
	begin
		case(i)
			0:	rx <= 0;
			1:	rx <= top[0];
			2:	rx <= top[1];
			3:	rx <= top[2];
			4:	rx <= top[3];
			5:	rx <= top[4];
			6:	rx <= top[5];	
			7:	rx <= top[6];
			8:	rx <= top[7];	
			9:	rx <= 1;
		default:rx <= 1;
		endcase
		#(5208*20);  //每次发送1位数据延时时钟周期个数乘以时钟周期      
	end               
endtask	

top top_inst
(
.clk    (clk  )  ,
.rst_n  (rst_n)  ,
.rx     (rx   )  ,

.ds     	()  ,
.oe_n    	()  ,
.shcp   	()  ,
.stcp   	()  
);



endmodule 




