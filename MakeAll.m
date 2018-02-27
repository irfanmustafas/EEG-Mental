close all; clear; clc;

load('sInfo.mat');
% ������ ���� ���� ó�� (E080-2�� 'EEG-.txt'�� EEG-2.txt'�� ���� ����)
sInfo(75,10) = 4;       % E077-4 ������ 2048�̶� ���� �Է��� ��
sInfo(76,10) = 4;       % E078-4 ������ 2048�̶� ���� �Է��� ��
sInfo(112,8) = 0;       % E114-4 ���� �������� �ʾ� ���� �Է��� ��
sInfo(118,8) = 0;       % E120-4 ���� �������� �ʾ� ���� �Է��� ��
sInfo(1,5)   = 0;       % E003-1�� ȥ�� ������ ���̰� �� ���� �Է��� ��

pSize = size(sInfo);
% ������ ID �ּ� iID, ������ ��ȯ �ּ� iSym, ������ ���� �ּ� iAge, �ൿ ���� ���� �ּ� iHav, 
iID = 1; iSym = 2; iGen = 3; iAge = 4; iHav = 10; iDO = 12;

elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

REP_DIR  = './Rep/';
TF256.tWin     = 0.50;
TF256.tShift   = 0.10;
TF256.Fs       = 256;                           % 256 Hz Resolution
TF256.frange   = [4 50];                        % 4~50 Hz ����
TF256.nWin     = fix(TF256.tWin*TF256.Fs);      % nWin�� Fs�� ����(0.05)�� ����, 128
TF256.nShift   = fix(TF256.tShift*TF256.Fs);    % nShift�� Fs�� 1/10(0.1)�� ������ ����, 25
TF256.nFFT     = 2^nextpow2(TF256.nWin);        % nWin�� ���� ����� 2�� �ŵ����� �� ���ϱ�
TF256.f_idx = [];

TF2048.tWin     = 0.50;
TF2048.tShift   = 0.10;
TF2048.Fs       = 2048;                         % 2048 Hz Resolution
TF2048.frange   = [4 50];                       % 4~50 Hz ����
TF2048.nWin     = fix(TF2048.tWin*TF2048.Fs);   % nWin�� Fs�� ����(0.05)�� ����, 128
TF2048.nShift   = fix(TF2048.tShift*TF2048.Fs); % nShift�� Fs�� 1/10(0.1)�� ������ ����, 25
TF2048.nFFT     = 2^nextpow2(TF2048.nWin);      % nWin�� ���� ����� 2�� �ŵ����� �� ���ϱ�
TF2048.f_idx = [];

dPath = '';


%% TXT Raw DATA EEGLAB �����ͷ� ��ȯ ���� (SaveSet.m)
% for p = 1:pSize(1)
%     % �ߵ� ����(Drop)�� ������ �� ���� ó���� ������ �پ�ѱ�
%     if sInfo(p, iDO), continue, end
%     
%     % �ൿ ���� �߰��Ǿ��� ���� 2048Hz ����
%     cLimit = sInfo(p,iHav);
%     
%     for q = 1:5
%         dPath = sprintf('E%03d-%d',sInfo(p,iID),q);
%         
%         % ���� ó�� (E080-2�� 'EEG-.txt'�� EEG-2.txt'�� ���� ����)
%         % E003-1�� ȥ�� ������ ���̰� ��,
%         if strcmp(dPath, 'E003-1'), continue, end
%         % E114-4 ������ ����
%         if strcmp(dPath, 'E114-4'), continue, end
%         % E120-4 ������ ����
%         if strcmp(dPath, 'E120-4'), continue, end
%         % iAge+q ��ġ�� �����Ͱ� �ִ��� ������ ���� ���� ��� ������
%         if ~sInfo(p,iAge+q), continue, end
%         
%         disp(dPath);
%         if q < cLimit || cLimit == 0
%             TF256.lines = SaveSet256(dPath, nCh, TF256, elocs);
%         else
%             TF2048.lines = SaveSet2048(dPath, nCh, TF2048, elocs);
%         end
%         
%         if isempty(TF256.f_idx)
%             set_name = [dPath '.set'];
%             EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
%             
%             % F�� ���� �Ҵ�(TF.f_idx) ���� �ѹ� ���� ����
%             [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF256.nWin,TF256.nWin-TF256.nShift,TF256.nFFT,TF256.Fs);
%             TF256.f_idx    = (F>=TF256.frange(1)) & (F<=TF256.frange(2));    % Frequencey �ĳ���
%             TF256.freq     = F(TF256.f_idx);
%             TF256.time     = T;
%             % 4~50 Hz �ش��ϴ� Frequencey�� �ĳ�
%         end
%         
%         if isempty(TF2048.f_idx)
%             set_name = [dPath '.set'];
%             EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
%             
%             % F�� ���� �Ҵ�(TF.f_idx) ���� �ѹ� ���� ����
%             [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF2048.nWin,TF2048.nWin-TF2048.nShift,TF2048.nFFT,TF2048.Fs);
%             TF2048.f_idx    = (F>=TF2048.frange(1)) & (F<=TF2048.frange(2));    % Frequencey �ĳ���
%             TF2048.freq     = F(TF2048.f_idx);
%             TF2048.time     = T;
%             % 4~50 Hz �ش��ϴ� Frequencey�� �ĳ�
%         end
%     end
% end
% % TF �� ������ ���� ���� ����
% save([REP_DIR 'TF.mat'], 'TF256', 'TF2048')


%% EEGLAB ������ �о Raw Power �� ��� (GetPwr256.m) - ��� 256Hz

% % TF �� �ҷ�����
% load([REP_DIR 'TF.mat'])
% % ������ ID, ��ȯ ����, ����, ����, �湮 Ƚ��, Power�� -> n x 6 ���
% tempPwr = cell(1,6);    % �� �����ͺ� �� �ӽ� ����
% tPwr256 = cell(0,6);    % ��ü ������ �� ����
% 
% for p = 1:pSize(1)
%     % �ߵ� ����(Drop)�� ������ �پ�ѱ�
%     if sInfo(p, iDO), continue, end
%     
%     for q = 1:5
%         dPath = sprintf('E%03d-%d',sInfo(p,iID),q);
%         
%         % ���� ó���� iAge+q ��ġ�� Ȯ���ؼ� ���� 0�� ��� ������
%         if ~sInfo(p,iAge+q), continue, end
%         
%         disp(dPath);
%         
%         % Pwr ������ nCh(2) x nFr(28: 0~54 2����) x nTm (19144)
%         % 25/256 = 0.0977�� ����, ������ ũ�� TF.tShift�� 0.1�� ��������
%         % 1870���� �� 10 ��(256/25 = 10.24��) �� �� �� 19144 ũ�Ⱑ ��
%         % �տ��� 256Hz�� ��� ����� ������ GetPwr256�� TF256���� ����
%         Pwr = GetPwr256(dPath, nCh, TF256);
%         save([REP_DIR dPath '_Pwr' '.mat'], 'Pwr')
% 
%         % ��ü �� ��Ƽ� ������ ����
%         % tempPwr(1,1:6) = {pID, pSym, pGen, pAge, pVst, Pwr};
%         % tPwr256 = cat(1, tPwr256, tempPwr);
%     end
% end
% 
% % ��ü �� ��Ƽ� ������ ����
% % save([REP_DIR 'tPwr256.mat'], 'tPwr256', '-v7.3')

%% EEGLAB ������ �о Wavelet Power �� ��� (GetWav256.m)
% % TF �� �ҷ�����
% load([REP_DIR 'TF.mat'])
% 
% msTime = TF256.lines/TF256.Fs*1000;
% WT.width    = 5;
% WT.gwidth   = 3;
% WT.freq     = TF256.frange(1):1:TF256.frange(2);
% if WT.freq(1) == 0, WT.freq(1) = []; end    % ������ 0�� ���Ե� ��� ����, Wavelet�� 0�� �ǹ� ����
% WT.time     = (0:20:(msTime-1/TF256.Fs))*0.001;   % 0.02�� ���� ����
% WT.fs       = 1/(WT.time(2)-WT.time(1));    % ������ ������ 0.02�ʷ� fs�� 50��
% WT.nFr         = length(WT.freq);
% WT.nTm         = length(WT.time);
% 
% save([REP_DIR 'WT.mat'], 'WT')
% 
% % tempWav =  cell(1, 6);  % �� �����ͺ� �� �ӽ� ���� ����
% wPwr256 = cell(0,6);    % ��ü ������ �� ����
% 
% for p = 1:pSize(1)
%     % �ߵ� ����(Drop)�� ������ �پ�ѱ�
%     if sInfo(p, iDO), continue, end
%     
%     for q = 1:5
%         dPath = sprintf('E%03d-%d',sInfo(p,iID),q);
%         
%         % ���� ó���� iAge+q ��ġ�� Ȯ���ؼ� ���� 0�� ��� ������
%         if ~sInfo(p,iAge+q), continue, end
%     
%         disp(dPath);
%         % Wav ������ nCh(2) x nFr(55: 1~55) x nTm (93500, 0.02�� ���� 1870��)
%         Wav = GetWav256(dPath, nCh, WT);
%         save([REP_DIR dPath '_Wav' '.mat'], 'Wav')
%         
%         % ������ �� ���� ���� ����
%         % tempWav(1,1:6) = {pID, pSym, pGen, pAge, pVst, Wav};
%     end
% end


%% �� Raw Power ���� Band �� Sperctarl Power ���
% load([REP_DIR 'WT.mat'])
% 
% % ���� ����, https://en.wikipedia.org/wiki/Electroencephalography
% thFreq  = (WT.freq >= 4)  & (WT.freq < 8);
% apFreq  = (WT.freq >= 8)  & (WT.freq < 13);
% btLFreq = (WT.freq >= 13) & (WT.freq < 20);
% btHFreq = (WT.freq >= 20) & (WT.freq < 30);
% gmFreq  = (WT.freq >= 30) & (WT.freq <= 50);
% 
% % �� �����ͺ� �� �ӽ� ����
% thWav  =  cell(1, 6);
% apWav  =  cell(1, 6);
% btLWav =  cell(1, 6);
% btHWav =  cell(1, 6);
% gmWav  =  cell(1, 6);
% 
% for p = 1:pSize(1)
%     % �ߵ� ����(Drop)�� ������ �پ�ѱ�
%     if sInfo(p, iDO), continue, end
%     
%     % pID ������ ID, pSym ��ȯ ����, pGen ����, pAge ����
%     pID = sInfo(p,iID); pSym = sInfo(p,iSym); pGen = sInfo(p,iGen); pAge = sInfo(p,iAge);
%     
%     for q = 1:5
%         % �湮 Ƚ�� pVst
%         pVst = q;
%         dPath = sprintf('E%03d-%d',sInfo(p,iID),q);
%         
%         % ���� ó���� iAge+q ��ġ�� Ȯ���ؼ� ���� 0�� ��� ������
%         if ~sInfo(p,iAge+q), continue, end    
%     
%         disp(dPath);
%         load([REP_DIR dPath '_Wav' '.mat'])
% 
%         thPwr   = squeeze(nanmean(Wav(:,thFreq,:),2));
%         apPwr   = squeeze(nanmean(Wav(:,apFreq,:),2));
%         btLPwr  = squeeze(nanmean(Wav(:,btLFreq,:),2));
%         btHPwr  = squeeze(nanmean(Wav(:,btHFreq,:),2));
%         gmPwr   = squeeze(nanmean(Wav(:,gmFreq,:),2));
%         
%         thWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, thPwr};
%         apWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, apPwr};
%         btLWav(1,1:6)   = {pID, pSym, pGen, pAge, pVst, btLPwr};
%         btHWav(1,1:6)   = {pID, pSym, pGen, pAge, pVst, btHPwr};
%         gmWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, gmPwr};
%         
%         save([REP_DIR dPath '_thWav' '.mat'], 'thWav')
%         save([REP_DIR dPath '_apWav' '.mat'], 'apWav')
%         save([REP_DIR dPath '_btLWav' '.mat'], 'btLWav')
%         save([REP_DIR dPath '_btHWav' '.mat'], 'btHWav')
%         save([REP_DIR dPath '_gmWav' '.mat'], 'gmWav')        
%     end
% end


%% �ڱ� ���� ���� �� �� Band�� ��
load([REP_DIR 'WT.mat'])

% Feature ���� 8��:
% (1) ó�� 3�� / (2) ó�� 5�� / (3) 60�� �� 3�� / (4) 60�� �� 5��
% (5) 120�� �� 3�� / (6) 120�� �� 5�� / (7) �߰� 100�� / (8) ��ü 300��
tStart1 = [10 320 630 940 1250 1570];
t3End1  = tStart1 + 3;
t5End1  = tStart1 + 5;
tStart2 = tStart1 + 60;
t3End2  = tStart2 + 3;
t5End2  = tStart2 + 5;
tStart3 = tStart1 + 120;
t3End3  = tStart3 + 3;
t5End3  = tStart3 + 5;
tStartM = tStart1 + 100;
tEndM = tStart1 + 200;
tEnd    = tStart1 + 300;

% ���� ��ȯ�� �ּ�(index) ���� ���� ����
sm = size(tStart1);
iStart1 = zeros(sm);
i3End1  = zeros(sm);
i5End1  = zeros(sm);
iStart2 = zeros(sm);
i3End2  = zeros(sm);
i5End2  = zeros(sm);
iStart3 = zeros(sm);
i3End3  = zeros(sm);
i5End3  = zeros(sm);
iStartM = zeros(sm);
iEndM   = zeros(sm);
iEnd    = zeros(sm);

% �ð� ������ �ּ� ������ ��ȯ
for t = 1:sm(2)
   [~,iStart1(t)]   = min(abs(WT.time-tStart1(t)));
   [~,i3End1(t)]    = min(abs(WT.time-t3End1(t)));
   [~,i5End1(t)]    = min(abs(WT.time-t5End1(t)));
   [~,iStart2(t)]   = min(abs(WT.time-tStart2(t)));
   [~,i3End2(t)]    = min(abs(WT.time-t3End2(t)));
   [~,i5End2(t)]    = min(abs(WT.time-t5End2(t)));
   [~,iStart3(t)]   = min(abs(WT.time-tStart3(t)));
   [~,i3End3(t)]    = min(abs(WT.time-t3End3(t)));
   [~,i5End3(t)]    = min(abs(WT.time-t5End3(t)));
   [~,iStartM(t)]   = min(abs(WT.time-tStartM(t)));
   [~,iEndM(t)]     = min(abs(WT.time-tEndM(t)));
   [~,iEnd(t)]      = min(abs(WT.time-tEnd(t)));
end

% �� �����ں� ���� �о�� �Ŀ� ���
% �� Feature ��: Channel �� 2�� X �ڱ� 6�� X Band ���� 5�� X Feature ���� 8�� = 480��
% Channel�� ���� 2�� ������ Channel1 - Channel2 �� ���̵� ����غ� �ǹ� ����
% �� Ȯ���� ���� �ϴ� ä�� 2���� ���� �غ��� ä�� ���̴� ���߿� �غ����
pN = 5; cN = 2; sN = 6; bN = 5; fN = 8;
pMatrix    = zeros(cN, sN, bN, fN);
pTable     = zeros(1,pN + cN*sN*bN*fN);      % 480 + 5;
totalTable256  = zeros(0,pN + cN*sN*bN*fN);      % ��ü ������ �����

for p = 1:pSize(1)
    % �ߵ� ����(Drop)�� ������ �پ�ѱ�
    if sInfo(p, iDO), continue, end
 
    % ���� ���������� �ٲ�� ������ qLimit ǥ�ñ�����, qLimit ���ʹ� 2048Hz
    for q = 1:5
        dPath = sprintf('E%03d-%d',sInfo(p,iID),q);
        
        % ���� ó���� iAge+q ��ġ�� Ȯ���ؼ� ���� 0�� ��� ������
        if ~sInfo(p,iAge+q), continue, end      
    
        disp(dPath);

        load([REP_DIR dPath '_thWav' '.mat'])
        load([REP_DIR dPath '_apWav' '.mat'])
        load([REP_DIR dPath '_btLWav' '.mat'])
        load([REP_DIR dPath '_btHWav' '.mat'])
        load([REP_DIR dPath '_gmWav' '.mat'])
        
        % ������ �⺻ ���� 5�� �ű��
        pTable(1:5) = cell2mat(gmWav(1:5));
        
        % band �� Feature ���, 2ä�� ������ �Ѿ��.
        % �ڱ� ���� 6�� ���� �� ��������, ������ 6�� ��� �� ������ �ڱظ� ���̴� ��.
        for t = 1:sm(2)
            pMatrix(:,t,1,1) = nanmean(thWav{6}(:,iStart1(t):i3End1(t)), 2);
            pMatrix(:,t,1,2) = nanmean(thWav{6}(:,iStart1(t):i5End1(t)), 2);
            pMatrix(:,t,1,3) = nanmean(thWav{6}(:,iStart2(t):i3End2(t)), 2);
            pMatrix(:,t,1,4) = nanmean(thWav{6}(:,iStart2(t):i5End2(t)), 2);
            pMatrix(:,t,1,5) = nanmean(thWav{6}(:,iStart3(t):i3End3(t)), 2);
            pMatrix(:,t,1,6) = nanmean(thWav{6}(:,iStart3(t):i5End3(t)), 2);
            pMatrix(:,t,1,7) = nanmean(thWav{6}(:,iStartM(t):iEndM(t)), 2);
            pMatrix(:,t,1,8) = nanmean(thWav{6}(:,iStart1(t):iEnd(t)), 2);
            
            pMatrix(:,t,2,1) = nanmean(apWav{6}(:,iStart1(t):i3End1(t)), 2);
            pMatrix(:,t,2,2) = nanmean(apWav{6}(:,iStart1(t):i5End1(t)), 2);
            pMatrix(:,t,2,3) = nanmean(apWav{6}(:,iStart2(t):i3End2(t)), 2);
            pMatrix(:,t,2,4) = nanmean(apWav{6}(:,iStart2(t):i5End2(t)), 2);
            pMatrix(:,t,2,5) = nanmean(apWav{6}(:,iStart3(t):i3End3(t)), 2);
            pMatrix(:,t,2,6) = nanmean(apWav{6}(:,iStart3(t):i5End3(t)), 2);
            pMatrix(:,t,2,7) = nanmean(apWav{6}(:,iStartM(t):iEndM(t)), 2);
            pMatrix(:,t,2,8) = nanmean(apWav{6}(:,iStart1(t):iEnd(t)), 2);
            
            pMatrix(:,t,3,1) = nanmean(btLWav{6}(:,iStart1(t):i3End1(t)), 2);
            pMatrix(:,t,3,2) = nanmean(btLWav{6}(:,iStart1(t):i5End1(t)), 2);
            pMatrix(:,t,3,3) = nanmean(btLWav{6}(:,iStart2(t):i3End2(t)), 2);
            pMatrix(:,t,3,4) = nanmean(btLWav{6}(:,iStart2(t):i5End2(t)), 2);
            pMatrix(:,t,3,5) = nanmean(btLWav{6}(:,iStart3(t):i3End3(t)), 2);
            pMatrix(:,t,3,6) = nanmean(btLWav{6}(:,iStart3(t):i5End3(t)), 2);
            pMatrix(:,t,3,7) = nanmean(btLWav{6}(:,iStartM(t):iEndM(t)), 2);
            pMatrix(:,t,3,8) = nanmean(btLWav{6}(:,iStart1(t):iEnd(t)), 2);
            
            pMatrix(:,t,4,1) = nanmean(btHWav{6}(:,iStart1(t):i3End1(t)), 2);
            pMatrix(:,t,4,2) = nanmean(btHWav{6}(:,iStart1(t):i5End1(t)), 2);
            pMatrix(:,t,4,3) = nanmean(btHWav{6}(:,iStart2(t):i3End2(t)), 2);
            pMatrix(:,t,4,4) = nanmean(btHWav{6}(:,iStart2(t):i5End2(t)), 2);
            pMatrix(:,t,4,5) = nanmean(btHWav{6}(:,iStart3(t):i3End3(t)), 2);
            pMatrix(:,t,4,6) = nanmean(btHWav{6}(:,iStart3(t):i5End3(t)), 2);
            pMatrix(:,t,4,7) = nanmean(btHWav{6}(:,iStartM(t):iEndM(t)), 2);
            pMatrix(:,t,4,8) = nanmean(btHWav{6}(:,iStart1(t):iEnd(t)), 2);
            
            pMatrix(:,t,5,1) = nanmean(gmWav{6}(:,iStart1(t):i3End1(t)), 2);
            pMatrix(:,t,5,2) = nanmean(gmWav{6}(:,iStart1(t):i5End1(t)), 2);
            pMatrix(:,t,5,3) = nanmean(gmWav{6}(:,iStart2(t):i3End2(t)), 2);
            pMatrix(:,t,5,4) = nanmean(gmWav{6}(:,iStart2(t):i5End2(t)), 2);
            pMatrix(:,t,5,5) = nanmean(gmWav{6}(:,iStart3(t):i3End3(t)), 2);
            pMatrix(:,t,5,6) = nanmean(gmWav{6}(:,iStart3(t):i5End3(t)), 2);
            pMatrix(:,t,5,7) = nanmean(gmWav{6}(:,iStartM(t):iEndM(t)), 2);
            pMatrix(:,t,5,8) = nanmean(gmWav{6}(:,iStart1(t):iEnd(t)), 2);
        end
        
        for t1 = 0:(cN-1)
            for t2 = 0:(sN-1)
                for t3 = 0:(bN-1)
                    for t4 = 1:fN
                        pTable(pN + t1*sN*bN*fN + t2*bN*fN + t3*fN + t4) = ...
                            pMatrix(t1+1,t2+1,t3+1,t4);
                    end
                end
            end
        end

        % ��ü ������ ���� ����
        totalTable256 = cat(1, totalTable256, pTable);
    end
    
    save([REP_DIR 'totalTable256.mat'], 'totalTable256', '-v7.3')
end

xlswrite('totalTable256.xlsx', totalTable256)
