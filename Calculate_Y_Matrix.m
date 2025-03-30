function admittanceMatrix = Calculate_Y_Matrix(nodeData, branchData, numNodes, numBranches)
% ����ڵ㵼�ɾ��� (Y ����)
% Y_Matrix == admittanceMatrix  
% �������:
%   nodeData - �ڵ����ݾ���
%   branchData - ֧·���ݾ���
%   numNodes - �ܽڵ���
%   numBranches - ��֧·��
% ���:
%   admittanceMatrix - ����õ��ĵ��ɾ���

    % ��ʼ�����ɾ��� Y Ϊ�����
    admittanceMatrix = zeros(numNodes);

    % ��ȡ֧·���迹�͵�����Ϣ
    impedance = complex(branchData(:,3), branchData(:,4));  % ���迹 (R + jX)
    shuntAdmittance = 1i * branchData(:,5);  % ֧·�Եص��� (jB)
    transformerRatio = branchData(:,6);   % ��ѹ�����
    fromBus = branchData(:,1);  % ��ʼ�ڵ�
    toBus = branchData(:,2);    % ��ֹ�ڵ�

    % ��ʼ����ѹ����Ч����
    admittanceT0 = zeros(numBranches, 1);  % ��ѹ����Ч���� (����ֵ)
    admittanceT1 = zeros(numBranches, 1);  % ���Ӱ���� 1
    admittanceT2 = zeros(numBranches, 1);  % ���Ӱ���� 2

    % �����ѹ����Ч����
    for k = 1:numBranches
        if transformerRatio(k) ~= 0
            admittanceT0(k) = 1 / transformerRatio(k) / impedance(k);
            admittanceT1(k) = (1 - transformerRatio(k)) / (transformerRatio(k)^2 * impedance(k));
            admittanceT2(k) = (transformerRatio(k) - 1) / (transformerRatio(k) * impedance(k));
        end
    end

    % ������ͨ��·�ĵ��ɾ��� (�ޱ�ѹ��)
    for k = 1:numBranches
        if transformerRatio(k) == 0
            admittanceMatrix(fromBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), fromBus(k)) + 1 / impedance(k) + 0.5 * shuntAdmittance(k);
            admittanceMatrix(fromBus(k), toBus(k)) = admittanceMatrix(fromBus(k), toBus(k)) - 1 / impedance(k);
            admittanceMatrix(toBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), toBus(k));
            admittanceMatrix(toBus(k), toBus(k)) = admittanceMatrix(toBus(k), toBus(k)) + 1 / impedance(k) + 0.5 * shuntAdmittance(k);
        end
    end

    % ������б�ѹ���ĵ��ɾ���
    for k = 1:numBranches
        if transformerRatio(k) ~= 0
            admittanceMatrix(fromBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), fromBus(k)) + admittanceT0(k) + admittanceT1(k);
            admittanceMatrix(fromBus(k), toBus(k)) = admittanceMatrix(fromBus(k), toBus(k)) - admittanceT0(k);
            admittanceMatrix(toBus(k), fromBus(k)) = admittanceMatrix(fromBus(k), toBus(k));
            admittanceMatrix(toBus(k), toBus(k)) = admittanceMatrix(toBus(k), toBus(k)) + admittanceT0(k) + admittanceT2(k);
        end
    end

    % ��ӽڵ�Եص���
    for k = 1:numNodes
        admittanceMatrix(k, k) = admittanceMatrix(k, k) + complex(nodeData(k,9), nodeData(k,10));  % �Եص���
    end
end
