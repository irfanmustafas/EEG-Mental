close all; clear; clc;

load('S2048.mat');
Sinfo(75,10) = 4;    % E077-4 번부터 2048이라 직접 입력해 줌
Sinfo(76,10) = 4;    % E078-4 번부터 2048이라 직접 입력해 줌
Sinfo(112,10) = 0;    % E114-4 번이 존재하지 않아 직접 입력해 줌.
Sinfo(118,10) = 0;    % E120-4 번이 존재하지 않아 직접 입력해 줌.

pSize = size(Sinfo);
% 피험자 ID 주소 iID, 피험자 질환 주소 iSym, 피험자 성별 주소 iAge, 행동 실험 여부 주소 iHav, 
iID = 1; iSym = 2; iGen = 3; iAge = 4; iHav = 10; iDO = 12;

elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

REP_DIR  = './Rep/';
TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = 2048;                  % 2048 Hz Resolution
TF.frange   = [0 55];                % 0~55 Hz 범위
TF.nWin     = fix(TF.tWin*TF.Fs);    % nWin은 Fs의 절반(0.05)로 설정, 128
TF.nShift   = fix(TF.tShift*TF.Fs);  % nShift는 Fs의 1/10(0.1)의 정수로 설정, 25
TF.nFFT     = 2^nextpow2(TF.nWin);      % nWin과 가장 가까운 2의 거듭제곱 수 구하기
TF.f_idx = [];

dPath = '';
pwr2048 = cell(0,6);


%% TXT Raw DATA EEGLAB 데이터로 변환 과정 (SaveSet2048.m)
for p = 1:pSize(1)
    if Sinfo(p, iDO), continue, end
    
    cLimit = Sinfo(p,iHav);
    if TF.Fs == 256
        qStart = 1;
        if cLimit == 0, qLimit = 5;
        else qLimit = cLimit - 1; end
    elseif TF.Fs == 2048
        qStart = cLimit;
        qLimit = 5;
    end
       
    % 프로토콜 여부에 따라 앞에서 qStart와 qLimit이 정의됨
    for q = qStart:qLimit
        dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
        
        % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
        % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
        % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
        if strcmp(dPath, 'E003-1'), continue, end
        if strcmp(dPath, 'E004-1'), continue, end
        if ~Sinfo(p,iAge+q), continue, end
        % 256Hz인 경우 지나가는 조건 추가
        if ~cLimit, continue, end
        
        disp(dPath);
        TF.lines = SaveSet2048(dPath, nCh, TF, elocs);
        
        if isempty(TF.f_idx)
            set_name = [dPath '.set'];
            EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
            
            % F값 범위 할당(TF.f_idx) 위해 한번 먼저 실행
            [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF.nWin,TF.nWin-TF.nShift,TF.nFFT,TF.Fs);
            TF.f_idx    = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey 쳐내기
            TF.freq     = F(TF.f_idx);
            TF.time     = T;
            % 0~55 Hz 해당하는 Frequencey만 쳐냄
        end
    end
end
% TF 값 다음에 쓰기 위해 저장
save([REP_DIR 'TF.mat'], 'TF')


%% EEGLAB 데이터 읽어서 Raw Power 값 기록 (GetPwr256.m)
% % imagesc 함수로 flot 할 것 아니면 여기서 만든 Power로 Band Spectrum을 분석하지는 않음
% 
% % TF 값 불러오기
% load([REP_DIR 'TF.mat'])
% % 피험자 ID, 질환 증상, 성별, 나이, 방문 횟수, Power값 -> n x 6 행렬
% tempPwr =  cell(1, 6);     % 각 데이터별 값 임시 저장
% tPwr256 = cell(0,6);    % 전체 데이터 값 저장
% 
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%     
%     % pID 피험자 ID, pSym 질환 증상, pGen 성별, pAge 나이
%     pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
%     
%     % 실험 프로토콜이 바뀌기 전까지 qLimit 표시까지만, qLimit 부터는 2048Hz
%     for q = 1:qLimit
%         % 방문 횟수 pVst
%         pVst = q;
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
%         % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
%         % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end        
%     
%         disp(dPath);
%         % Pwr 구조는 nCh(2) x nFr(28: 0~54 2간격) x nTm (19144)
%         % 25/256 = 0.0977초 간격, 윈도우 크기 TF.tShift를 0.1로 정했으니
%         % 1870초의 약 10 배(256/25 = 10.24배) 좀 더 된 19144 크기가 됨
%         Pwr = GetPwr256(dPath, nCh, TF);
%         tempPwr(1,1:6) = {pID, pSym, pGen, pAge, pVst, Pwr};
%         save([REP_DIR dPath '_Pwr' '.mat'], 'Pwr')
%         
%         tPwr256 = cat(1, tPwr256, tempPwr);
%     end
% end
% save([REP_DIR 'tPwr256.mat'], 'tPwr256', '-v7.3')


%% EEGLAB 데이터 읽어서 Wavelet Power 값 기록 (GetWav256.m)
% % TF 값 불러오기
% load([REP_DIR 'TF.mat'])
% 
% msTime = TF.lines/TF.Fs*1000;
% WT.width    = 5;
% WT.gwidth   = 3;
% WT.freq     = TF.frange(1):1:TF.frange(2);
% if WT.freq(1) == 0, WT.freq(1) = []; end    % 범위에 0이 포함된 경우 제거, Wavelet은 0값 의미 없음
% WT.time     = (0:20:(msTime-1/Fs))*0.001;   % 0.02초 간격 설정
% WT.fs       = 1/(WT.time(2)-WT.time(1));    % 위에서 간격이 0.02초로 fs는 50됨
% WT.nFr         = length(WT.freq);
% WT.nTm         = length(WT.time);
% 
% save([REP_DIR 'WT.mat'], 'WT')
% 
% tempWav =  cell(1, 6);  % 각 데이터별 값 임시 저장
% wPwr256 = cell(0,6);    % 전체 데이터 값 저장
% 
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%     
%     % pID 피험자 ID, pSym 질환 증상, pGen 성별, pAge 나이
%     pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
%     
%     % 실험 프로토콜이 바뀌기 전까지 qLimit 표시까지만, qLimit 부터는 2048Hz
%     for q = 1:qLimit
%         % 방문 횟수 pVst
%         pVst = q;
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
%         % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
%         % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end        
%     
%         disp(dPath);
%         % Wav 구조는 nCh(2) x nFr(55: 1~55) x nTm (93500, 0.02초 간격 1870초)
%         Wav = GetWav256(dPath, nCh, WT);
%         tempWav(1,1:6) = {pID, pSym, pGen, pAge, pVst, Wav};
%         save([REP_DIR dPath '_Wav' '.mat'], 'Wav')
%     end
% end
% 
% % 전체 저장용 wPwr256 변수 만들기 위해 별도로 돌리기 (메모리 부족 예상)
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%     
%     % pID 피험자 ID, pSym 질환 증상, pGen 성별, pAge 나이
%     pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
%     
%     % 실험 프로토콜이 바뀌기 전까지 qLimit 표시까지만, qLimit 부터는 2048Hz
%     for q = 1:qLimit
%         % 방문 횟수 pVst
%         pVst = q;
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
%         % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
%         % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end        
%     
%         disp(dPath);
%         load([REP_DIR dPath '_Wav' '.mat'])
%         tempWav(1,1:6) = {pID, pSym, pGen, pAge, pVst, Wav};
%         wPwr256 = cat(1, wPwr256, tempWav);
%     end
% end
% save([REP_DIR 'wPwr256.mat'], 'wPwr256', '-v7.3')


%% 각 Raw Power 마다 Band 별 Sperctarl Power 계산
% load([REP_DIR 'WT.mat'])
% 
% % 영역 선택, https://en.wikipedia.org/wiki/Electroencephalography
% gmFreq  = (WT.freq >= 30) & (WT.freq <= 55);
% muFreq  = (WT.freq >= 8) & (WT.freq < 12);
% apFreq  = (WT.freq >= 8) & (WT.freq < 15);
% btFreq  = (WT.freq >= 15) & (WT.freq < 30);
% thFreq  = (WT.freq >= 4) & (WT.freq < 8);
% dtFreq  = (WT.freq >= 0.2) & (WT.freq < 4);
% 
% % 각 데이터별 값 임시 저장
% gmWav =  cell(1, 6);
% muWav =  cell(1, 6);
% apWav =  cell(1, 6);
% btWav =  cell(1, 6);
% thWav =  cell(1, 6);
% dtWav =  cell(1, 6);
% 
% % 각 Band 별 별도 파일 저장
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%     
%     % pID 피험자 ID, pSym 질환 증상, pGen 성별, pAge 나이
%     pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
%     
%     % 실험 프로토콜이 바뀌기 전까지 qLimit 표시까지만, qLimit 부터는 2048Hz
%     for q = 1:qLimit
%         % 방문 횟수 pVst
%         pVst = q;
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
%         % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
%         % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end        
%     
%         disp(dPath);
%         load([REP_DIR dPath '_Wav' '.mat'])
%         
%         gmPwr   = squeeze(nanmean(Wav(:,gmFreq,:),2));
%         muPwr   = squeeze(nanmean(Wav(:,muFreq,:),2));
%         apPwr   = squeeze(nanmean(Wav(:,apFreq,:),2));
%         btPwr   = squeeze(nanmean(Wav(:,btFreq,:),2));
%         thPwr   = squeeze(nanmean(Wav(:,thFreq,:),2));
%         dtPwr   = squeeze(nanmean(Wav(:,dtFreq,:),2));
%         
%         gmWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, gmPwr};
%         muWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, muPwr};
%         apWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, apPwr};
%         btWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, btPwr};
%         thWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, thPwr};
%         dtWav(1,1:6)    = {pID, pSym, pGen, pAge, pVst, dtPwr};
%         
%         save([REP_DIR dPath '_gmWav' '.mat'], 'gmWav')
%         save([REP_DIR dPath '_muWav' '.mat'], 'muWav')
%         save([REP_DIR dPath '_apWav' '.mat'], 'apWav')
%         save([REP_DIR dPath '_btWav' '.mat'], 'btWav')
%         save([REP_DIR dPath '_thWav' '.mat'], 'thWav')
%         save([REP_DIR dPath '_dtWav' '.mat'], 'dtWav')
%         
%     end
% end


%% 자극 구간 설정 후 각 Band별 값
% load([REP_DIR 'WT.mat'])
% 
% % Feature 구간 8개:
% % (1) 처음 3초 / (2) 처음 5초 / (3) 60초 후 3초 / (4) 60초 후 5초
% % (5) 120초 후 3초 / (6) 120초 후 5초 / (7) 중간 100초 / (8) 전체 300초
% tStart1 = [10 320 630 940 1250 1570];
% t3End1  = tStart1 + 3;
% t5End1  = tStart1 + 5;
% tStart2 = tStart1 + 60;
% t3End2  = tStart2 + 3;
% t5End2  = tStart2 + 5;
% tStart3 = tStart1 + 120;
% t3End3  = tStart3 + 3;
% t5End3  = tStart3 + 5;
% tStartM = tStart1 + 100;
% tEndM = tStart1 + 200;
% tEnd    = tStart1 + 300;
% 
% % 실제 변환된 주소(index) 저장 변수 지정
% sm = size(tStart1);
% iStart1 = zeros(sm);
% i3End1  = zeros(sm);
% i5End1  = zeros(sm);
% iStart2 = zeros(sm);
% i3End2  = zeros(sm);
% i5End2  = zeros(sm);
% iStart3 = zeros(sm);
% i3End3  = zeros(sm);
% i5End3  = zeros(sm);
% iStartM = zeros(sm);
% iEndM   = zeros(sm);
% iEnd    = zeros(sm);
% 
% % 시간 구간을 주소 값으로 변환
% for t = 1:sm(2)
%    [~,iStart1(t)]   = min(abs(WT.time-tStart1(t)));
%    [~,i3End1(t)]    = min(abs(WT.time-t3End1(t)));
%    [~,i5End1(t)]    = min(abs(WT.time-t5End1(t)));
%    [~,iStart2(t)]   = min(abs(WT.time-tStart2(t)));
%    [~,i3End2(t)]    = min(abs(WT.time-t3End2(t)));
%    [~,i5End2(t)]    = min(abs(WT.time-t5End2(t)));
%    [~,iStart3(t)]   = min(abs(WT.time-tStart3(t)));
%    [~,i3End3(t)]    = min(abs(WT.time-t3End3(t)));
%    [~,i5End3(t)]    = min(abs(WT.time-t5End3(t)));
%    [~,iStartM(t)]   = min(abs(WT.time-tStartM(t)));
%    [~,iEndM(t)]     = min(abs(WT.time-tEndM(t)));
%    [~,iEnd(t)]      = min(abs(WT.time-tEnd(t)));
% end
% 
% % 각 피험자별 파일 읽어온 후에 계산
% % 총 Feature 수: Channel 수 2개 X 자극 6개 X Band 구간 6개 X Feature 구간 8개 = 576개
% % Channel은 원래 2개 이지만 Channel1 - Channel2 뺀 차이도 기록해볼 의미 있음
% % 값 확인을 위해 일단 채널 2개만 먼저 해보고 채널 차이는 나중에 해보기로
% pN = 5; cN = 2; sN = 6; bN = 6; fN = 8;
% pMatrix = zeros(cN, sN, bN, fN);
% pTable = zeros(1,581);      % 576 + 5;
% tTable256 = zeros(0,581);      % 전체 피험자 저장용
% 
% for p = 1:pSize(1)
%     if Sinfo(p, iDO), continue, end
%     
%     cLimit = Sinfo(p,iHav);
%     if cLimit == 0, qLimit = 5;
%     else qLimit = cLimit - 1; end
%  
%     % 실험 프로토콜이 바뀌기 전까지 qLimit 표시까지만, qLimit 부터는 2048Hz
%     for q = 1:qLimit
%         dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
%         
%         % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
%         % E003-1은 혼자 데이터 길이가 감, E004-1은 2번 채널이 없음
%         % iAge+q 위치는 데이터가 있는지 없는지 봐서 없는 경우 지나감
%         if strcmp(dPath, 'E003-1'), continue, end
%         if strcmp(dPath, 'E004-1'), continue, end
%         if ~Sinfo(p,iAge+q), continue, end        
%     
%         disp(dPath);
%         load([REP_DIR dPath '_gmWav' '.mat'])
%         load([REP_DIR dPath '_muWav' '.mat'])
%         load([REP_DIR dPath '_apWav' '.mat'])
%         load([REP_DIR dPath '_btWav' '.mat'])
%         load([REP_DIR dPath '_thWav' '.mat'])
%         load([REP_DIR dPath '_dtWav' '.mat'])
%         
%         % 피험자 기본 정보 5개 옮기기
%         pTable(1:5) = cell2mat(gmWav(1:5));
%         
%         % band 별 Feature 얻기, 2채널 정보로 넘어옴.
%         % 자극 구간 6개 별로 더 만들어야함, 지금은 6번 계산 후 마지막 자극만 쌓이는 것.
%         for t = 1:sm(2)
%             pMatrix(:,t,1,1) = nanmean(gmWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,1,2) = nanmean(gmWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,1,3) = nanmean(gmWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,1,4) = nanmean(gmWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,1,5) = nanmean(gmWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,1,6) = nanmean(gmWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,1,7) = nanmean(gmWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,1,8) = nanmean(gmWav{6}(:,iStart1(t):iEnd(t)), 2);
%             
%             pMatrix(:,t,2,1) = nanmean(muWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,2,2) = nanmean(muWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,2,3) = nanmean(muWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,2,4) = nanmean(muWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,2,5) = nanmean(muWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,2,6) = nanmean(muWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,2,7) = nanmean(muWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,2,8) = nanmean(muWav{6}(:,iStart1(t):iEnd(t)), 2);
%             
%             pMatrix(:,t,3,1) = nanmean(apWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,3,2) = nanmean(apWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,3,3) = nanmean(apWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,3,4) = nanmean(apWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,3,5) = nanmean(apWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,3,6) = nanmean(apWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,3,7) = nanmean(apWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,3,8) = nanmean(apWav{6}(:,iStart1(t):iEnd(t)), 2);
%             
%             pMatrix(:,t,4,1) = nanmean(btWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,4,2) = nanmean(btWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,4,3) = nanmean(btWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,4,4) = nanmean(btWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,4,5) = nanmean(btWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,4,6) = nanmean(btWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,4,7) = nanmean(btWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,4,8) = nanmean(btWav{6}(:,iStart1(t):iEnd(t)), 2);
%             
%             pMatrix(:,t,5,1) = nanmean(thWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,5,2) = nanmean(thWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,5,3) = nanmean(thWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,5,4) = nanmean(thWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,5,5) = nanmean(thWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,5,6) = nanmean(thWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,5,7) = nanmean(thWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,5,8) = nanmean(thWav{6}(:,iStart1(t):iEnd(t)), 2);
%             
%             pMatrix(:,t,6,1) = nanmean(dtWav{6}(:,iStart1(t):i3End1(t)), 2);
%             pMatrix(:,t,6,2) = nanmean(dtWav{6}(:,iStart1(t):i5End1(t)), 2);
%             pMatrix(:,t,6,3) = nanmean(dtWav{6}(:,iStart2(t):i3End2(t)), 2);
%             pMatrix(:,t,6,4) = nanmean(dtWav{6}(:,iStart2(t):i5End2(t)), 2);
%             pMatrix(:,t,6,5) = nanmean(dtWav{6}(:,iStart3(t):i3End3(t)), 2);
%             pMatrix(:,t,6,6) = nanmean(dtWav{6}(:,iStart3(t):i5End3(t)), 2);
%             pMatrix(:,t,6,7) = nanmean(dtWav{6}(:,iStartM(t):iEndM(t)), 2);
%             pMatrix(:,t,6,8) = nanmean(dtWav{6}(:,iStart1(t):iEnd(t)), 2);
%         end
%         
%         for t1 = 0:(cN-1)
%             for t2 = 0:(sN-1)
%                 for t3 = 0:(bN-1)
%                     for t4 = 1:fN
%                         pTable(pN + t1*sN*bN*fN + t2*bN*fN + t3*fN + t4) = ...
%                             pMatrix(t1+1,t2+1,t3+1,t4);
%                     end
%                 end
%             end
%         end
% 
%         % 전체 변수에 누적 저장
%             tTable256 = cat(1, tTable256, pTable);
%     end
%     
%     save([REP_DIR 'tTable256.mat'], 'tTable256', '-v7.3')
% end

% xlswrite('tTable256.xlsx', tTable256)
