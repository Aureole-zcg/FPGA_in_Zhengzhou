### 时序约束完整分类汇总表

| 大类 | 子类型 | 核心作用与场景 | 典型命令/示例（SDC风格） |
| :--- | :--- | :--- | :--- |
| **1. 时钟定义与特性** | **主时钟 (Primary Clock)** | 定义从芯片外部输入的板级时钟源（如晶振）。 | `create_clock -period 10 [get_ports SYS_CLK]` |
| | **虚拟时钟 (Virtual Clock)** | 定义外部器件的时钟，用于IO约束，在FPGA内部无物理连接。 | `create_clock -name VIRT_CLK -period 5` |
| | **衍生时钟 (Generated Clock)** | 定义由PLL、MMCM或寄存器分频/倍频产生的内部时钟。 | `create_generated_clock -divide_by 2 -source [get_pins PLL/CLKIN] [get_pins REG/Q]` |
| | **时钟非理想特性** | 定义时钟的抖动(Jitter)、裕量(Uncertainty)和网络延迟(Latency)。 | `set_clock_uncertainty -setup 0.3 [get_clocks CLK]` |
| **2. I/O接口约束** | **输入延迟 (Input Delay)** | 约束外部芯片发送到FPGA输入引脚的数据与输入时钟的相对关系。 | `set_input_delay -clock CLK -max 2.5 [get_ports DIN]` |
| | **输出延迟 (Output Delay)** | 约束FPGA输出引脚到外部芯片数据的相对关系，满足外设建立/保持时间。 | `set_output_delay -clock CLK -min 0.5 [get_ports DOUT]` |
| | **偏移约束 (Offset)** | 早期的IO约束方式，直接规定数据与时钟沿的偏移量。 | `OFFSET = OUT 4ns AFTER CLK` |
| **3. 跨时钟域（CDC）与异步约束** <br>*(新增重点类别)* | **异步时钟组** | **核心CDC约束**。声明两个时钟域完全异步，工具不分析它们之间的时序路径（等同于批量False Path）。 | `set_clock_groups -asynchronous -group [get_clocks CLK_A] -group [get_clocks CLK_B]` |
| | **逻辑/物理独占时钟组** | 声明多个时钟在逻辑上不会同时存在，或物理上不能同时切换，用于减少无效时序分析。 | `set_clock_groups -logically_exclusive -group CLK_C -group CLK_D` |
| | **同步器属性约束** | 针对CDC常用的双/多级触发器打拍结构，赋予特定属性防止被优化并正确识别。 | `set_property ASYNC_REG TRUE [get_cells sync_reg_*]` （Xilinx）<br>`set_dont_touch [get_cells sync_reg_*]` |
| **4. 时序例外约束 (I)** <br>**伪路径与多周期** | **伪路径 (False Path)** | **明确指定**某条（些）路径在功能上永远不会被激活，**完全忽略**其建立/保持时间检查。 | `set_false_path -from [get_pins A] -to [get_pins B]` <br>`set_false_path -through [get_nets TEST_MODE]` |
| | **多周期路径 (Multicycle Path)** | 指定数据从起点到终点需要**多个时钟周期**才能稳定，放宽建立/保持时间的检查周期数。 | `set_multicycle_path -setup 2 -from CLK1 -to CLK2`（建立时间放宽至2个周期）<br>`set_multicycle_path -hold 1 -from CLK1 -to CLK2`（保持时间需同步前移） |
| **5. 时序例外约束 (II)** <br>**路径延迟覆盖** | **最大延迟 (Max Delay)** | 为特定路径强制指定一个**绝对的延迟上限**，覆盖默认的建立时间公式计算。 | `set_max_delay -from A -to B 5.0` |
| | **最小延迟 (Min Delay)** | 为特定路径强制指定一个**绝对的延迟下限**，覆盖默认的保持时间公式计算。 | `set_min_delay -from A -to B 1.0` |
| **6. 其他辅助约束** <br>*(新增汇总类别)* | **常量/静态电平约束** | 固定某个端口或节点为常量逻辑（0或1），用于简化特定模式下的时序分析。 | `set_case_analysis 0 [get_ports SEL_PIN]` |
| | **禁用时序弧** | 强制忽略某个单元内部特定引脚之间的时序弧（如复位引脚到Q的传输延迟）。 | `set_disable_timing -from RST -to Q [get_cells REG]` |
| | **时序分组与标签** | 将特定元件（如RAM、DSP、寄存器）分组命名，便于后续统一施加约束。 | `TNM_NET = [get_nets RESET] group_name` |
| | **物理位置/区域约束** | 间接影响时序的物理约束，将逻辑绑定到芯片特定位置或区域。 | `set_property LOC X0Y0 [get_cells inst]` <br>`set_property REGION X0Y0:X1Y1 [get_cells group]` |

---



1.  **关于伪路径 vs. 异步时钟组**：
    *   对于**少量跨时钟域的信号**（如单根控制信号），建议使用 `set_false_path -from ... -to ...` 进行精准“点对点”忽略。
    *   对于**整个时钟域**之间的大量数据传输（如双时钟FIFO），强烈建议使用 `set_clock_groups -asynchronous`，效率更高且不易遗漏。

2.  **关于多周期路径的坑**：
    *   设定 `set_multicycle_path -setup` 时，**必须同步调整 `-hold`**。通常情况，若建立时间放宽为 N 个周期，保持时间需调整为 N-1 个周期，否则保持时间违例会急剧恶化。

3.  **约束优先级（从高到低）**：
    **最大/最小延迟** > **伪路径/多周期路径** > **异步时钟组** > **I/O约束** > **时钟定义**。约束越具体、作用范围越小，优先级越高。

