function [iterationCount, jacobianMatrix, voltageMag, voltageAng] = Newton(numNodes, numPQ, conductanceMat, susceptanceMat, voltageMag, voltageAng, activePower, reactivePower, powerMismatch, deltaAng, deltaVolt)

% Newton-Raphson 法求解电力潮流
% 输入参数:
%   numNodes - 总节点数
%   numPQ - PQ 节点数
%   conductanceMat - 导纳矩阵实部（电导）
%   susceptanceMat - 导纳矩阵虚部（电纳）
%   voltageMag - 电压幅值 (初值)
%   voltageAng - 电压相角 (初值)
%   activePower - 有功功率
%   reactivePower - 无功功率
%   powerMismatch - 功率不平衡量 (初值)
%   deltaAng - 相角增量 (初值)
%   deltaVolt - 电压幅值增量 (初值)

maxIterations = 50; % 最大迭代次数限制
iterationCount = 1; % 计算迭代次数
tol_error = 1e-5;

while max(abs(powerMismatch)) > tol_error  % 误差收敛判断
    fprintf('第 %d 次迭代，误差：%e\n', iterationCount, max(abs(powerMismatch)));
    
    activePowerMismatch = zeros(numNodes-1,1); % 有功功率不平衡
    reactivePowerMismatch = zeros(numPQ,1); % 无功功率不平衡
    
    H = zeros(numNodes-1,numNodes-1);
    N = zeros(numNodes-1,numPQ);
    M = zeros(numPQ,numNodes-1);
    L = zeros(numPQ,numPQ);
    
    % 计算有功功率不平衡量
    for i = 1:numNodes-1
        for j = 1:numNodes 
            activePowerMismatch(i) = activePowerMismatch(i) + voltageMag(i) * voltageMag(j) * ...
                (conductanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)));
        end
        activePowerMismatch(i) = activePower(i) - activePowerMismatch(i);
    end
    
    % 计算无功功率不平衡量
    for i = 1:numPQ
        for j = 1:numNodes
            reactivePowerMismatch(i) = reactivePowerMismatch(i) + voltageMag(i) * voltageMag(j) * ...
                (conductanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)));
        end
        reactivePowerMismatch(i) = reactivePower(i) - reactivePowerMismatch(i);
    end
    
    powerMismatch = [activePowerMismatch; reactivePowerMismatch];
    
    % 计算雅可比矩阵
    for i = 1:numNodes-1
        for j = 1:numNodes-1
            if i ~= j 
                H(i,j) = -voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)));
            end
        end
    end
    
    for i = 1:numNodes-1
        for j = 1:numPQ
            if i ~= j 
                N(i,j) = -voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)));
            end
        end
    end
    
    for i = 1:numPQ
        for j = 1:numNodes-1
            if i ~= j 
                M(i,j) = voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)));
            end
        end
    end
    
    for i = 1:numPQ
        for j = 1:numPQ
            if i ~= j 
                L(i,j) = -voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)));
            end
        end
    end
    
    for i = 1:numNodes-1
        for j = 1:numNodes
            if i ~= j
                H(i,i) = H(i,i) + voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)));
            end
        end
    end
    
    for i = 1:numPQ
        for j = 1:numNodes
            if i ~= j                    
                N(i,i) = N(i,i) - voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)));
                M(i,i) = M(i,i) - voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)) + susceptanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)));
                L(i,i) = L(i,i) - voltageMag(i) * voltageMag(j) * ...
                    (conductanceMat(i,j) * sin(voltageAng(i)-voltageAng(j)) - susceptanceMat(i,j) * cos(voltageAng(i)-voltageAng(j)));
            end
        end
        N(i,i) = N(i,i) - 2 * (voltageMag(i))^2 * conductanceMat(i,i);
        L(i,i) = L(i,i) + 2 * (voltageMag(i))^2 * susceptanceMat(i,i);
    end
    
    jacobianMatrix = [H, N; M, L]; % 雅可比矩阵
    
    deltaX = -jacobianMatrix \ powerMismatch; % 计算增量
    
    for i = 1:numNodes-1
        deltaAng(i) = deltaX(i);
        voltageAng(i) = voltageAng(i) + deltaAng(i); 
    end
    
    for i = 1:numPQ
        deltaVolt(i) = deltaX(i+numNodes-1) * voltageMag(i);
        voltageMag(i) = voltageMag(i) + deltaVolt(i);
    end
    
    iterationCount = iterationCount + 1;
    
    % 检查是否超过最大迭代次数,防止出现异常
   if iterationCount > maxIterations
        disp('超出最大迭代次数仍未收敛，程序终止');
        break;
    end
end

% 只有当误差足够小时，才打印"误差足够小"消息
if max(abs(powerMismatch)) <= tol_error
    fprintf('第 %d 次迭代，误差：%e 已经足够小\n', iterationCount, max(abs(powerMismatch)));
end
end

