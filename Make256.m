% close all; clear; clc;

load('S256.mat');
Sinfo(75,10) = 4;    % E077-4 ������ 2048�̶� ���� �Է��� ��
Sinfo(76,10) = 4;    % E078-4 ������ 2048�̶� ���� �Է��� ��

pSize = size(Sinfo);
% ������ ID �ּ� iID, ������ ��ȯ �ּ� iSym, ������ ���� �ּ� iAge, �ൿ ���� ���� �ּ� iHav, 
iID = 1; iSym = 2; iGen = 3; iAge = 4; iHav = 10; iDO = 12;

elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

REP_DIR  = './Rep/';
TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = 256;                   % 256 Hz Resolution
TF.frange   = [0 55];                % 0~55 Hz ����
TF.nWin     = fix(TF.tWin*TF.Fs);    % nWin�� Fs�� ����(0.05)�� ����, 128
TF.nShift   = fix(TF.tShift*TF.Fs);  % nShift�� Fs�� 1/10(0.1)�� ������ ����, 25
TF.nFFT     = 2^nextpow2(TF.nWin);      % nWin�� ���� ����� 2�� �ŵ����� �� ���ϱ�
TF.f_idx = [];

dPath = '';
pwr256 = cell(0,6);


%% TXT Raw DATA EEGLAB �����ͷ� ��ȯ ���� (SaveSet256.m)
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%        
%     % ���� ���������� �ٲ�� ������ qLimit ǥ�ñ�����, qLimit ���ʹ� 2048Hz
%     for q = 1:qLimit
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % ���� ó�� (E080-2�� 'EEG-.txt'�� EEG-2.txt'�� ���� ����)
%         % E003-1�� ȥ�� ������ ���̰� ��, E004-1�� 2�� ä���� ����
%         % iAge+q ��ġ�� �����Ͱ� �ִ��� ������ ���� ���� ��� ������
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end
%         
%         disp(dPath);
%         SaveSet256(dPath, nCh, TF, elocs);
%         
%         if isempty(TF.f_idx)
%             set_name = [dPath '.set'];
%             EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
%             
%             % F�� ���� �Ҵ�(TF.f_idx) ���� �ѹ� ���� ����
%             [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF.nWin,TF.nWin-TF.nShift,TF.nFFT,TF.Fs);
%             TF.f_idx    = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey �ĳ���
%             TF.freq     = F(TF.f_idx);
%             TF.time     = T;
%             % 0~55 Hz �ش��ϴ� Frequencey�� �ĳ�, ������ �� ������ �ƴϰ� +/- 1 ���� ��.
%             % F���� ������ ����� 0, 1.953125, 3.90625, 5.859375, 7.81250 ... ����
%         end
%     end
% end

%% EEGLAB ������ �о Raw Power �� ��� (GetPwr256.m)
% ������ ID, ��ȯ ����, ����, ����, �湮 Ƚ��, Power�� -> n x 6 ���
tempPwr =  cell(1, 6);     % �� �����ͺ� �� �ӽ� ����
tPwr256 = cell(0,6);    % ��ü ������ �� ����

for p = 1:pSize(1)
    if Sinfo(p, iDO), continue, end
    
    cLimit = Sinfo(p,iHav);
    if cLimit == 0, qLimit = 5;
    else qLimit = cLimit - 1; end
    
    % pID ������ ID, pSym ��ȯ ����, pGen ����, pAge ����
    pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
    
    % ���� ���������� �ٲ�� ������ qLimit ǥ�ñ�����, qLimit ���ʹ� 2048Hz
    for q = 1:qLimit
        % �湮 Ƚ�� pVst
        pVst = q;
        dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
        
        % ���� ó�� (E080-2�� 'EEG-.txt'�� EEG-2.txt'�� ���� ����)
        % E003-1�� ȥ�� ������ ���̰� ��, E004-1�� 2�� ä���� ����
        % iAge+q ��ġ�� �����Ͱ� �ִ��� ������ ���� ���� ��� ������
        if strcmp(dPath, 'E003-1'), continue, end
        if strcmp(dPath, 'E004-1'), continue, end
        if ~Sinfo(p,iAge+q), continue, end
        
        if isempty(TF.f_idx)
            set_name = [dPath '.set'];
            EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
            
            % F�� ���� �Ҵ�(TF.f_idx) ���� �ѹ� ���� ����
            [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF.nWin,TF.nWin-TF.nShift,TF.nFFT,TF.Fs);
            TF.f_idx    = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey �ĳ���
            TF.freq     = F(TF.f_idx);
            TF.time     = T;
            % 0~55 Hz �ش��ϴ� Frequencey�� �ĳ�, ������ �� ������ �ƴϰ� +/- 1 ���� ��.
            % F���� ������ ����� 0, 1.953125, 3.90625, 5.859375, 7.81250 ... ����
        end
        
        disp(dPath);
        Pwr = GetPwr256(dPath, nCh, TF);
        tempPwr(1,1:6) = {pID, pSym, pGen, pAge, pVst, Pwr};
        save([REP_DIR dPath '_Pwr' '.mat'], 'Pwr', '-v7.3')
        
        tPwr256 = cat(1, tPwr256, tempPwr);
    end
end
save([REP_DIR 'tPwr256.mat'], 'tPwr256', '-v7.3')


%% �� Raw Power ���� Band �� Sperctarl Power ���

% ���� ����, https://en.wikipedia.org/wiki/Electroencephalography
% gm_freq  = (WT.freq >= 30) & (WT.freq <= 55);
% mu_freq  = (WT.freq >= 8) & (WT.freq < 12);
% alpha_freq  = (WT.freq >= 8) & (WT.freq < 15);
% beta_freq = (WT.freq >= 15) & (WT.freq < 30);
% theta_freq = (WT.freq >= 4) & (WT.freq < 8);
% delta_freq = (WT.freq >= 0.2) & (WT.freq < 4);
