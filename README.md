# PowerFlow-IEEE-39Bus-Matlab ⚡ 
# Matlab 实现IEEE 10 机39 节点模型潮流计算

[查看项目代码](https://github.com/qeqeq1/PowerFlow-IEEE-39Bus-Matlab)   
[![MATLAB](https://img.shields.io/badge/MATLAB-R2022b%2B-blue.svg)](https://www.mathworks.com/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)  
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/)

## 📌 项目简介 | Project Overview

本项目为 **南京理工大学 自动化学院 智能电网信息工程专业及相关专业所学课程**  **电力系统分析理论** 的作业之一。   
提供 **基于 MATLAB** 的 **IEEE 39 节点电力系统潮流计算** 代码，采用 **牛顿-拉夫逊法**（Newton-Raphson Method）进行求解。

此项目为本人课程作业，预计不会有后续更新。但如果您发现任何问题，欢迎提出。

不得不提，本项目代码是我在现有项目的基础上简单调整而来的，参见本文末尾。

另外：强烈鄙视CSDN、知乎、哔哩哔哩上把一坨💩搬来搬去，并引流到公众号强行喂💩的行为。

🚀 **特点**：
- 采用 **牛顿-拉夫逊法** 计算潮流分布
- 适用于 **IEEE 39-bus 系统** ，但只要修改`Node_Data_1.xlsx`   和`Branch_Data_1.xlsx`  ，理论上任何节点数目都适用。
- **MATLAB 实现**，理论上适配 **R2022b 及以上版本**，其他版本请自行测试
- **数据格式简单**，支持 Excel 直接输入

---

## 📂 文件结构 | File Structure

| 文件名 File Name               | 功能描述 Description                                                   |
|--------------------------------|------------------------------------------------------------------------|
| `Node_Data_1.xlsx`            | **节点参数表**（类型/功率/电压） Node parameters (type/power/voltage)   |
| `Branch_Data_1.xlsx`          | **支路参数表**（阻抗/对地导纳） Branch parameters (impedance/shunt admittance) |
| `Calculate_Y_Matrix.m`        | **导纳矩阵生成** Y-matrix construction                                |
| `Newton.m`                    | **牛顿-拉夫逊法求解器** Newton-Raphson solver core                      |
| `Calculate_Branch.m`          | **支路潮流计算** Branch power flow calculation                         |
| `Calculate_Node.m`            | **节点功率平衡** Node power balance                                   |
| `Calculate_S_Power.m`         | **复功率计算** Complex power calculation                              |
| `IEEE_39_Node_Flow.m`         | **主文件** Main calculation workflow                              |

---

## 🚀 快速开始 | Quick Start

### 📌 环境要求 | Requirements
- MATLAB **R2022b 或更高版本** | or newer
- Excel/WPS **文件支持** | Excel/WPS support

### ⚡ 运行步骤 | Execution Steps
1. **下载** 本仓库内容
2. **打开 MATLAB**，进入项目目录
3. **打开 `IEEE_39_Node_Flow.m`** 文件并运行


### 🔍 示例数据 | Example Data


- `Node_Data_1.xlsx`

| 节点编号 | 节点类型（1PQ节点，2PV节点，3平衡节点） | 电压幅值U | 电压相位A | 发电机P | 发电机Q | 负荷P | 负荷Q | 对地电导G | 对地电纳B |
|----------|-----------------------------------------|-----------|-----------|---------|---------|-------|-------|-----------|-----------|
| 1        | 1                                       | 1         | 0         | 0       | 0       | 0     | 0     | 0         | 0         |
| 2        | 1                                       | 1         | 0         | 0       | 0       | 0     | 0     | 0         | 0         |
| 3        | 1                                       | 1         | 0         | 0       | 322     | 2.4   | 0     | 0         | 0         |
| 4        | 1                                       | 1         | 0         | 0       | 500     | 184   | 0     | 0         | 0         |
| 5        | 1                                       | 1         | 0         | 0       | 0       | 0     | 0     | 0         | 0         |
| 6        | 1                                       | 1         | 0         | 0       | 0       | 0     | 0     | 0         | 0         |
| 7        | 1                                       | 1         | 0         | 0       | 233.8   | 84    | 0     | 0         | 0         |

- `Branch_Data_1.xlsx`

| 首端编号 | 末端编号 | 线路电阻 | 线路电抗 | 线路电纳 | 变压器变比标幺值（1表示线路） |
|----------|----------|----------|----------|----------|---------------------------------|
| 1        | 2        | 0.0035   | 0.0411   | 0.6987   | 1                               |
| 1        | 39       | 0.001    | 0.025    | 0.75     | 1                               |
| 2        | 3        | 0.0013   | 0.0151   | 0.2572   | 1                               |
| 2        | 25       | 0.007    | 0.0086   | 0.146    | 1                               |
| 3        | 4        | 0.0013   | 0.0213   | 0.2214   | 1                               |
| 3        | 18       | 0.0011   | 0.0133   | 0.2138   | 1                               |
| 4        | 5        | 0.0008   | 0.0128   | 0.1342   | 1                               |


---

### 📊 计算结果示例 | Sample Results

- 线路潮流计算结果 | Branch Power Flow Results

```matlab

==================== 线路、支路潮流计算结果 ====================
| 起点 | 终点 | 入端功率 (MW) | 出端功率 (MW) | 功率损耗 (MW) |
---------------------------------------------------------------
|    1 |    2 |     -186.5152 |       187.6936 |        1.1784 |
|    1 |   39 |      186.5152 |      -186.1785 |        0.3367 |
|    2 |    3 |      313.8536 |      -312.2909 |        1.5627 |
```


- 节点潮流计算结果 | Node Power Flow Results
  
```matlab

==================== 节点潮流计算结果 ====================
| 节点 | 类型 | 发电功率 (MW) | 负荷功率 (MW) | 电压幅值 (p.u) | 相位角 (°) |
--------------------------------------------------------------------------------
|    1 | Slack |        0.0000 |         0.0000 |         1.0249 |       2.54 |
|    2 | PQ    |        0.0000 |         100.00 |         1.0244 |       6.78 |
|    3 | PV    |      200.0000 |         80.000 |         0.9969 |       4.24 |
```


---

## 📖 参考资料 | References

- [IEEE39_PowerFlowCalculation_Matlab GitHub.com/fxm-fxm](https://github.com/fxm-fxm/IEEE39_PowerFlowCalculation_Matlab)
- [CloudPSS IEEE 39-bus Example](https://legacy.kb.cloudpss.net/zh/examples/IEEE39.html)
---

## 📜 许可协议 | License

本项目采用 **MIT 许可证**  
**MIT License**

