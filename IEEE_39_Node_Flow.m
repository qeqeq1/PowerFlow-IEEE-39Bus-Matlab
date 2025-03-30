clear; clc;
%%
% PQ节点 
% 对于PQ节点，已知该节点的有功功率(P)和无功功率(Q)，
% 但其电压幅值和电压相角是通过潮流计算求解的。
% 这种节点通常用于表示负荷节点，电力系统中的用户或负载点。

% PV节点 
% 对于PV节点，已知该节点的有功功率(P)和电压幅值(V)，
% 电压相角是通过潮流计算来求解的。
% 这种节点通常用于发电机或变电站，电压幅值通常设定为固定值（如1 p.u.），
% 而电压相角则需要计算得到。

% 平衡节点 (Slack Node)
% 平衡节点，也叫参考节点，是潮流计算中的一个特殊节点，
% 主要用于确保系统的总功率平衡。它通过吸收或释放剩余的功率来平衡系统中的功率。
% 平衡节点的电压幅值和电压相角通常已知，且不随潮流计算结果变化。
% 在潮流计算中，平衡节点是唯一可以调整其功率的节点，
% 它的功率变化会自动调节整个电力系统的功率平衡，因此被选作系统的参考点。
%%
% 读取支路数据（Branch_Data_1.xlsx）
% 支路数据包括支路的起始节点、终止节点、阻抗（Z），以及其他与支路有关的参数
% 读取节点数据（Node_Data_1.xlsx）
% 节点数据包括节点的编号、节点类型（如PQ、PV或平衡节点，以1 2 3代替。具体参考文件）、电压幅值、电压相角、功率需求等
% 原实验要求文件给出数据疑似存在错误，已进行必要的修正，
% 对于数值中出现的,已经替换为. p9已修改为pq。数值以 潮流计算编程作业.docx 给出为准，未作改动。
%%
% 读取节点和支路数据
nodeInfo = readmatrix('Node_Data_1.xlsx');
gridBranchInfo = readmatrix('Branch_Data_1.xlsx');

% 确定节点总数和 PQ 节点数
numNodes = size(nodeInfo, 1);  % 总节点数
numPQNodes = 0;  % PQ 节点数
for index = 1:numNodes
    if nodeInfo(index, 2) ~= 1
        numPQNodes = index - 1;
        break;
    end
end
numBranches = size(gridBranchInfo, 1);  % 支路总数

% 计算导纳矩阵（Y 矩阵），用于电力潮流计算
admittanceMatrix = Calculate_Y_Matrix(nodeInfo, gridBranchInfo, numNodes, numBranches);
conductanceMatrix = real(admittanceMatrix);  % 取实部作为电导矩阵
susceptanceMatrix = imag(admittanceMatrix);  % 取虚部作为电纳矩阵

% 初始化节点功率数据
powerInjection = zeros(numNodes, 1);
for index = 1:numNodes
    % 计算复功率 S = (P - PL - QL * j) * 0.01
    powerInjection(index) = 0.01 * (nodeInfo(index, 5) - nodeInfo(index, 7) - nodeInfo(index, 8) * 1i);
end
activePower = real(powerInjection);  % 有功功率 P
reactivePower = imag(powerInjection);  % 无功功率 Q

% 初始化电压幅值
voltageMagnitude = ones(numNodes, 1);  % 默认所有节点初始电压为 1 p.u.
for index = numPQNodes + 1:numNodes
    voltageMagnitude(index) = nodeInfo(index, 3);  % 读取已知电压幅值
end
voltageAngle = zeros(numNodes, 1);  % 电压相角初值

% 初始化牛顿法求解参数
powerMismatch = ones(numNodes + numPQNodes - 1, 1);
previousError = zeros(numNodes + numPQNodes - 1, 1);
previousVoltage = zeros(numNodes + numPQNodes - 1, 1);

% 采用牛顿法求解电压幅值和相角
[iterationCount, jacobianMatrix, voltageMagnitude, voltageAngle] = Newton(...
    numNodes, numPQNodes, conductanceMatrix, susceptanceMatrix, voltageMagnitude, voltageAngle, ...
    activePower, reactivePower, powerMismatch, previousError, previousVoltage);

% 计算相角并转换为角度制
degreeAngle = voltageAngle .* 180 / pi;

% 计算节点电压向量（复数形式）
voltageVector = zeros(numNodes, 1);
for index = 1:numNodes
    voltageVector(index) = voltageMagnitude(index) * cos(voltageAngle(index)) + ...
                           voltageMagnitude(index) * sin(voltageAngle(index)) * 1i;
end

% 计算净注入功率
totalPowerInjection = Calculate_S_Power(voltageMagnitude, voltageAngle, conductanceMatrix, susceptanceMatrix, numNodes);

% 输出支路潮流计算结果
fprintf('\n==================== 线路、支路潮流计算结果 ====================\n');
fprintf('| 起点 | 终点 | 入端功率 (MW) | 出端功率 (MW) | 功率损耗 (MW) |\n');
fprintf('---------------------------------------------------------------\n');
branchFlowResults = Calculate_Branch(gridBranchInfo, voltageMagnitude, numNodes, numBranches, admittanceMatrix, voltageVector);
for i = 1:size(branchFlowResults,1)
    fprintf('| %4d | %4d | %13.4f | %14.4f | %13.4f |\n', ...
        branchFlowResults(i,1), branchFlowResults(i,2), branchFlowResults(i,3), branchFlowResults(i,4), branchFlowResults(i,5));
end
fprintf('---------------------------------------------------------------\n');

% 输出节点潮流计算结果
fprintf('\n==================== 节点潮流计算结果 ====================\n');
fprintf('| 节点 | 类型 | 发电功率 (MW) | 负荷功率 (MW) | 电压幅值 (p.u) | 相位角 (°) |\n');
fprintf('--------------------------------------------------------------------------------\n');
nodeFlowResults = Calculate_Node(nodeInfo, branchFlowResults, numNodes, numBranches, voltageMagnitude, admittanceMatrix, voltageVector, degreeAngle);
for i = 1:size(nodeFlowResults,1)
    fprintf('| %4d | %4d | %13.4f | %14.4f | %14.4f | %10.2f |\n', ...
        nodeFlowResults(i,1), nodeFlowResults(i,2), nodeFlowResults(i,3), nodeFlowResults(i,4), nodeFlowResults(i,5), nodeFlowResults(i,6));
end
fprintf('--------------------------------------------------------------------------------\n');

