# 50MHz主时钟时序约束
#create_clock -period 20 -name clk [get_ports clk]

# ========== IO电平标准 LVCMOS33 全部端口 ==========
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports led0]
set_property IOSTANDARD LVCMOS33 [get_ports led1]
set_property IOSTANDARD LVCMOS33 [get_ports led2]
set_property IOSTANDARD LVCMOS33 [get_ports led3]

# ========== 物理引脚绑定 PACKAGE_PIN ==========
set_property PACKAGE_PIN V4 [get_ports clk]
set_property PACKAGE_PIN P14 [get_ports rst_n]
set_property PACKAGE_PIN E21 [get_ports led0]
set_property PACKAGE_PIN D21 [get_ports led1]
set_property PACKAGE_PIN E22 [get_ports led2]
set_property PACKAGE_PIN D22 [get_ports led3]


