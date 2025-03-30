function admittanceMatrix = Calculate_Y_Matrix(nodeData, branchData, numNodes, numBranches)
% 计算节点导纳矩阵 (Y 矩阵)
% Y_Matrix == admittanceMatrix  
% 输入参数:
%   nodeData - 节点数据矩阵
%   branchData - 支路数据矩阵
%   numNodes - 总节点数
%   numBranches - 总支路数
% 输出:
%   admittanceMatrix - 计算得到的导纳矩阵

    % 初始化导纳矩阵 Y 为零矩阵
    admittanceMatrix = zeros(numNodes);

    % 获取支路的阻抗和导纳信息
    impedance = complex(branchData(:,3), branchData(:,4));  % 复阻抗 (R + jX)
    shuntAdmittance = 1i * branchData(:,5);  % 支路对地电纳 (jB)
    transformerRatio = branchData(:,6);   % 变压器变比
    fromBus = branchData(:,1);  % 起始节点
    toBus = branchData(:,2);    % 终止节点

    % 初始化变压器等效导纳
    admittanceT0 = zeros(numBranches, 1);  % 变压器等效导纳 (基本值)
    admittanceT1 = zeros(numBranches, 1);  % 变比影响项 1
    admittanceT2 = zeros(numBranches, 1);  % 变比影响项 2

    % 计算变压器等效导纳
    for k = 1:numBranches
        if transformerRatio(k) ~= 0
            admittanceT0(k) = 1 / transformerRatio(k) / impedance(k);
            admittanceT1(k) = (1 - transformerRatio(k)) / (transformerRatio(k)^2 * impedance(k));
            admittanceT2(k) = (transformerRatio(k) - 1) / (transformerRatio(k) * impedance(k));
        end
    end

    % 计算普通线路的导纳矩阵 (无变压器)
    for k = 1:numBranches
        if transformerRatio(k) == 0
            admittanceMatrix(fromBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), fromBus(k)) + 1 / impedance(k) + 0.5 * shuntAdmittance(k);
            admittanceMatrix(fromBus(k), toBus(k)) = admittanceMatrix(fromBus(k), toBus(k)) - 1 / impedance(k);
            admittanceMatrix(toBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), toBus(k));
            admittanceMatrix(toBus(k), toBus(k)) = admittanceMatrix(toBus(k), toBus(k)) + 1 / impedance(k) + 0.5 * shuntAdmittance(k);
        end
    end

    % 计算带有变压器的导纳矩阵
    for k = 1:numBranches
        if transformerRatio(k) ~= 0
            admittanceMatrix(fromBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), fromBus(k)) + admittanceT0(k) + admittanceT1(k);
            admittanceMatrix(fromBus(k), toBus(k)) = admittanceMatrix(fromBus(k), toBus(k)) - admittanceT0(k);
            admittanceMatrix(toBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), toBus(k));
            admittanceMatrix(toBus(k), toBus(k)) = admittanceMatrix(toBus(k), toBus(k)) + admittanceT0(k) + admittanceT2(k);
        end
    end

    % 添加节点对地导纳
    for k = 1:numNodes
        admittanceMatrix(k, k) = admittanceMatrix(k, k) + complex(nodeData(k,9), nodeData(k,10));  % 对地导纳
    end
end
