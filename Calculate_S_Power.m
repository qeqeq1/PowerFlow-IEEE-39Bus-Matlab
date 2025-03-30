function complexPower = Calculate_S_Power(voltageMag, voltageAng, conductanceMat, susceptanceMat, numNodes)
% 计算节点的复功率 S = P + jQ
% S Power means ComplexPower
% 输入参数:
%   voltageMag - 电压幅值
%   voltageAng - 电压相角
%   conductanceMat - 导纳矩阵实部（电导）
%   susceptanceMat - 导纳矩阵虚部（电纳）
%   numNodes - 总节点数
% 输出:
%   complexPower - 复功率向量 (单位: 100MVA)

    activePower = zeros(numNodes, 1);  % 有功功率 P
    reactivePower = zeros(numNodes, 1); % 无功功率 Q

    % 计算每个节点的 P 和 Q
    for i = 1:numNodes
        for j = 1:numNodes
            activePower(i) = activePower(i) + voltageMag(i) * voltageMag(j) * ...
                (conductanceMat(i,j) * cos(voltageAng(i) - voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i) - voltageAng(j)));

            reactivePower(i) = reactivePower(i) + voltageMag(i) * voltageMag(j) * ...
                (conductanceMat(i,j) * sin(voltageAng(i) - voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i) - voltageAng(j)));
        end
    end

    % 计算复功率 S
    complexPower = complex(activePower, reactivePower) * 100; % 以 100MVA 作为标幺值
end
