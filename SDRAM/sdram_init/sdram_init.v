module sdram_init 
#(
    parameter Power_waiting = 20000, //时钟频率100MHz 100us=10000个时钟周期

    parameter tRP = 2, //预充电命令周期
    parameter tRFC = 7, //自刷新命令周期
    parameter tMRD = 3, //模式寄存器设置命令周期

    parameter refresh_MAX = 2, //自动刷新次数

    parameter NOP_CMD = 4'b0111,//空操作命令
    parameter PRECHARGE_CMD = 4'b0010, //预充电命令
    parameter AUTO_REFRESH_CMD = 4'b0001, //自动刷新命令
    parameter LOAD_MODE_REGISTER_CMD = 4'b0000 //配置模式寄存器命令
)
(
    input wire clk_100MHz,
    input wire rst_n,

    output reg [3:0] init_cmd,
    output reg [12:0] init_addr,//0~8191
    output reg [1:0] init_ba,//bank address
    output wire init_end //激活（初始化）成功标志
);

localparam idle = 4'd0;
localparam precharge = 4'd1;//预充电命令
localparam t_RP = 4'd2;//预充电命令执行周期
localparam auto_refresh = 4'd3;//自动刷新
localparam t_RFC = 4'd4;//自动刷新执行周期
localparam load_mode_register = 4'd5;//配置模式寄存器（激活）
localparam t_MRD = 4'd6;//模式寄存器设置命令周期
localparam end_active = 4'd7;//激活完成，结束状态

reg [15:0] cnt_power;//上电等待计数器
reg power_en;//上电使能信号
reg [3:0] cnt_clk;//状态保持时间计数器
reg cnt_clk_rst;//状态保持时间计数器重置信号

reg [3:0] state;//状态机

reg [1:0] cnt_refresh;//计数自动刷新次数，至少两次
reg t_RP_end;//预充电命令执行周期结束标志
reg t_RFC_end;//自动刷新执行周期结束标志
reg t_MRD_end;//模式寄存器设置命令周期结束标志

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        cnt_power <= 0;
    else if (cnt_power < Power_waiting)
            cnt_power <= cnt_power + 1;
        else
            cnt_power <= cnt_power;
end

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        power_en <= 1'b0;
    else if (cnt_power == Power_waiting - 1'b1)
            power_en <= 1'b1;
        else
            power_en <= 1'b0;
end

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        cnt_clk <= 4'd0;
    else if (cnt_clk_rst ==  1'b0)
            cnt_clk <= cnt_clk + 1'b1;
        else 
            cnt_clk <= 4'd0;//复位信号高电平进行计数器复位
end

always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        state <= idle;
    else 
    begin 
        case (state)
        idle : if (power_en == 1'b1) state <= precharge;
        
        precharge : state <= t_RP;

        t_RP : if (t_RP_end == 1'b1) state <= auto_refresh;

        auto_refresh : state <= t_RFC;

        t_RFC : begin
          if (t_RFC_end == 1'b1 && cnt_refresh < refresh_MAX )
            state <= auto_refresh;
        else if (t_RFC_end == 1'b1 && cnt_refresh == refresh_MAX)
                state <= load_mode_register;
            else state <= state;
        end

        load_mode_register : state <= t_MRD;

        t_MRD : if (t_MRD_end == 1'b1) state <= end_active;

        default : state <= idle;//state == end_active，init_end作为激活（初始化）成功标志，只拉高一个周期
        endcase
    end
end

always @(*) 
begin
    if(~rst_n)
    cnt_clk_rst = 1'b1;
    else begin
        if (state == idle || state == end_active)
            cnt_clk_rst = 1'b1;
        else if (t_RP_end || t_RFC_end || t_MRD_end)
                cnt_clk_rst = 1'b1;
            else 
                cnt_clk_rst = 1'b0;
    end
end

//t_RP_end
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        t_RP_end <= 1'b0;
    else if (cnt_clk == tRP - 1'b1 && state == t_RP)
            t_RP_end <= 1'b1;
        else t_RP_end <= 1'b0;
end

//t_RFC_end
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        t_RFC_end <= 1'b0;
    else if (cnt_clk == tRFC - 1'b1 && state == t_RFC)
            t_RFC_end <= 1'b1;
        else t_RFC_end <= 1'b0;
end

//t_MRD_end
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        t_MRD_end <= 1'b0;
    else if (cnt_clk == tMRD - 1'b1 && state == t_MRD)
            t_MRD_end <= 1'b1;
        else t_MRD_end <= 1'b0;
end

//cnt_refresh
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        cnt_refresh <= 2'd0;
    else if (state == auto_refresh)
            cnt_refresh <= cnt_refresh + 1'b1;
        else cnt_refresh <= cnt_refresh;
end

//output pin area
//init_cmd
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        init_cmd <= NOP_CMD;
    else if (state == precharge)
            init_cmd <= PRECHARGE_CMD;
        else if (state == t_RP)
                init_cmd <= NOP_CMD;
            else if (state == auto_refresh)
                    init_cmd <= AUTO_REFRESH_CMD;
                else if (state == t_RFC)
                        init_cmd <= NOP_CMD;
                    else if (state == load_mode_register)
                            init_cmd <= LOAD_MODE_REGISTER_CMD;
                        else 
                            init_cmd <= NOP_CMD;//state == t_MRD | end_active
end

//init_ba
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        init_ba <= 2'b11;//EN AUTO_REFRESH
    else if (state == load_mode_register)
            init_ba <= 2'b00;//DIS AP
        else init_ba <= 2'b11;//EN AP
end

//init_addr
always @(posedge clk_100MHz, negedge rst_n) 
begin
    if (~rst_n)
        init_addr <= 13'h1fff;//0001_1111_1111_1111
    else if (state == load_mode_register)//0_0000_0011_0111
            init_addr <= {
                            3'b000,//BA1(A12),BA0(A11),A10
                            1'b0,  //写入突发模式，0：编程设定的脉冲持续时间，1：单点访问方式
                            2'b00, //标准模式
                            3'b011,//潜伏期 3
                            1'b0,  //总线模式（突发类型） 0：顺序，1：交叉
                            3'b111 //整页显示，000：1，001：2，010：4，011：8
                         };
        else init_addr <= 13'h1fff;
end

assign init_end = (state == end_active)? 1'b1:1'b0;
endmodule
