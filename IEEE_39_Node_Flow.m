clear; clc;
%%
% PQ�ڵ� 
% ����PQ�ڵ㣬��֪�ýڵ���й�����(P)���޹�����(Q)��
% �����ѹ��ֵ�͵�ѹ�����ͨ�������������ġ�
% ���ֽڵ�ͨ�����ڱ�ʾ���ɽڵ㣬����ϵͳ�е��û����ص㡣

% PV�ڵ� 
% ����PV�ڵ㣬��֪�ýڵ���й�����(P)�͵�ѹ��ֵ(V)��
% ��ѹ�����ͨ���������������ġ�
% ���ֽڵ�ͨ�����ڷ��������վ����ѹ��ֵͨ���趨Ϊ�̶�ֵ����1 p.u.����
% ����ѹ�������Ҫ����õ���

% ƽ��ڵ� (Slack Node)
% ƽ��ڵ㣬Ҳ�вο��ڵ㣬�ǳ��������е�һ������ڵ㣬
% ��Ҫ����ȷ��ϵͳ���ܹ���ƽ�⡣��ͨ�����ջ��ͷ�ʣ��Ĺ�����ƽ��ϵͳ�еĹ��ʡ�
% ƽ��ڵ�ĵ�ѹ��ֵ�͵�ѹ���ͨ����֪���Ҳ��泱���������仯��
% �ڳ��������У�ƽ��ڵ���Ψһ���Ե����书�ʵĽڵ㣬
% ���Ĺ��ʱ仯���Զ�������������ϵͳ�Ĺ���ƽ�⣬��˱�ѡ��ϵͳ�Ĳο��㡣
%%
% ��ȡ֧·���ݣ�Branch_Data_1.xlsx��
% ֧·���ݰ���֧·����ʼ�ڵ㡢��ֹ�ڵ㡢�迹��Z�����Լ�������֧·�йصĲ���
% ��ȡ�ڵ����ݣ�Node_Data_1.xlsx��
% �ڵ����ݰ����ڵ�ı�š��ڵ����ͣ���PQ��PV��ƽ��ڵ㣬��1 2 3���档����ο��ļ�������ѹ��ֵ����ѹ��ǡ����������
% ԭʵ��Ҫ���ļ������������ƴ��ڴ����ѽ��б�Ҫ��������
% ������ֵ�г��ֵ�,�Ѿ��滻Ϊ. p9���޸�Ϊpq����ֵ�� ������������ҵ.docx ����Ϊ׼��δ���Ķ���
%%
% ��ȡ�ڵ��֧·����
nodeInfo = readmatrix('Node_Data_1.xlsx');
gridBranchInfo = readmatrix('Branch_Data_1.xlsx');

% ȷ���ڵ������� PQ �ڵ���
numNodes = size(nodeInfo, 1);  % �ܽڵ���
numPQNodes = 0;  % PQ �ڵ���
for index = 1:numNodes
    if nodeInfo(index, 2) ~= 1
        numPQNodes = index - 1;
        break;
    end
end
numBranches = size(gridBranchInfo, 1);  % ֧·����

% ���㵼�ɾ���Y ���󣩣����ڵ�����������
admittanceMatrix = Calculate_Y_Matrix(nodeInfo, gridBranchInfo, numNodes, numBranches);
conductanceMatrix = real(admittanceMatrix);  % ȡʵ����Ϊ�絼����
susceptanceMatrix = imag(admittanceMatrix);  % ȡ�鲿��Ϊ���ɾ���

% ��ʼ���ڵ㹦������
powerInjection = zeros(numNodes, 1);
for index = 1:numNodes
    % ���㸴���� S = (P - PL - QL * j) * 0.01
    powerInjection(index) = 0.01 * (nodeInfo(index, 5) - nodeInfo(index, 7) - nodeInfo(index, 8) * 1i);
end
activePower = real(powerInjection);  % �й����� P
reactivePower = imag(powerInjection);  % �޹����� Q

% ��ʼ����ѹ��ֵ
voltageMagnitude = ones(numNodes, 1);  % Ĭ�����нڵ��ʼ��ѹΪ 1 p.u.
for index = numPQNodes + 1:numNodes
    voltageMagnitude(index) = nodeInfo(index, 3);  % ��ȡ��֪��ѹ��ֵ
end
voltageAngle = zeros(numNodes, 1);  % ��ѹ��ǳ�ֵ

% ��ʼ��ţ�ٷ�������
powerMismatch = ones(numNodes + numPQNodes - 1, 1);
previousError = zeros(numNodes + numPQNodes - 1, 1);
previousVoltage = zeros(numNodes + numPQNodes - 1, 1);

% ����ţ�ٷ�����ѹ��ֵ�����
[iterationCount, jacobianMatrix, voltageMagnitude, voltageAngle] = Newton(...
    numNodes, numPQNodes, conductanceMatrix, susceptanceMatrix, voltageMagnitude, voltageAngle, ...
    activePower, reactivePower, powerMismatch, previousError, previousVoltage);

% ������ǲ�ת��Ϊ�Ƕ���
degreeAngle = voltageAngle .* 180 / pi;

% ����ڵ��ѹ������������ʽ��
voltageVector = zeros(numNodes, 1);
for index = 1:numNodes
    voltageVector(index) = voltageMagnitude(index) * cos(voltageAngle(index)) + ...
                           voltageMagnitude(index) * sin(voltageAngle(index)) * 1i;
end

% ���㾻ע�빦��
totalPowerInjection = Calculate_S_Power(voltageMagnitude, voltageAngle, conductanceMatrix, susceptanceMatrix, numNodes);

% ���֧·����������
fprintf('\n==================== ��·��֧·���������� ====================\n');
fprintf('| ��� | �յ� | ��˹��� (MW) | ���˹��� (MW) | ������� (MW) |\n');
fprintf('---------------------------------------------------------------\n');
branchFlowResults = Calculate_Branch(gridBranchInfo, voltageMagnitude, numNodes, numBranches, admittanceMatrix, voltageVector);
for i = 1:size(branchFlowResults,1)
    fprintf('| %4d | %4d | %13.4f | %14.4f | %13.4f |\n', ...
        branchFlowResults(i,1), branchFlowResults(i,2), branchFlowResults(i,3), branchFlowResults(i,4), branchFlowResults(i,5));
end
fprintf('---------------------------------------------------------------\n');

% ����ڵ㳱��������
fprintf('\n==================== �ڵ㳱�������� ====================\n');
fprintf('| �ڵ� | ���� | ���繦�� (MW) | ���ɹ��� (MW) | ��ѹ��ֵ (p.u) | ��λ�� (��) |\n');
fprintf('--------------------------------------------------------------------------------\n');
nodeFlowResults = Calculate_Node(nodeInfo, branchFlowResults, numNodes, numBranches, voltageMagnitude, admittanceMatrix, voltageVector, degreeAngle);
for i = 1:size(nodeFlowResults,1)
    fprintf('| %4d | %4d | %13.4f | %14.4f | %14.4f | %10.2f |\n', ...
        nodeFlowResults(i,1), nodeFlowResults(i,2), nodeFlowResults(i,3), nodeFlowResults(i,4), nodeFlowResults(i,5), nodeFlowResults(i,6));
end
fprintf('--------------------------------------------------------------------------------\n');

