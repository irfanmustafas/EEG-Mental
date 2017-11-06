close all; clear; clc;

load('S256.mat');
pSize = size(Sinfo);
iID = 1; iSym = 2; iGen = 3; iAge = 4; iHav = 10; iDO = 12;

elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

REP_DIR  = './Rep/';
TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = 256;                   % 256 Hz Resolution
TF.frange   = [0 55];                % 0~55 Hz 범위
TF.nWin     = fix(TF.tWin*TF.Fs);    % nWin은 Fs의 절반(0.05)로 설정, 128
TF.nShift   = fix(TF.tShift*TF.Fs);  % nShift는 Fs의 1/10(0.1)의 정수로 설정, 25
TF.nFFT     = 2^nextpow2(TF.nWin);      % nWin과 가장 가까운 2의 거듭제곱 수 구하기
TF.f_idx = [];

dPath = '';
pwr256 = cell(0,6);

for p = 1:pSize(1)
    if Sinfo(p, iDO), continue, end
    
    cLimit = Sinfo(p,iHav);
    if cLimit == 0, qLimit = 5;
    else qLimit = cLimit - 1; end
    
    pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
    
    for q = 1:qLimit
        pVst = q;
        dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
        
        % 예외 처리 (E080-2의 'EEG-.txt'는 EEG-2.txt'로 직접 변경)
        if strcmp(dPath, 'E004-1'), continue, end
        if ~Sinfo(p,iAge+q), continue, end
        
        disp(dPath);
        SaveSet256(dPath, nCh, TF, elocs);
        
        if isempty(TF.f_idx)
            set_name = [dPath '.set'];
            EEG = pop_loadset('filepath', REP_DIR, 'filename', set_name);
            
            % F값 범위 할당(TF.f_idx) 위해 한번 먼저 실행
            [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),TF.nWin,TF.nWin-TF.nShift,TF.nFFT,TF.Fs);
            TF.f_idx    = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey 쳐내기
            TF.freq     = F(TF.f_idx);
            TF.time     = T;
            % 0~55 Hz 해당하는 Frequencey만 쳐냄, 범위의 딱 절반은 아니고 +/- 1 정도 됨.
            % F값을 실제로 열어보면 0, 1.953125, 3.90625, 5.859375, 7.81250 ... 순서
        end
        


    end
end


% 영역 선택, https://en.wikipedia.org/wiki/Electroencephalography
gm_freq  = (WT.freq >= 30) & (WT.freq <= 55);
mu_freq  = (WT.freq >= 8) & (WT.freq < 12);
alpha_freq  = (WT.freq >= 8) & (WT.freq < 15);
beta_freq = (WT.freq >= 15) & (WT.freq < 30);
theta_freq = (WT.freq >= 4) & (WT.freq < 8);
delta_freq = (WT.freq >= 0.2) & (WT.freq < 4);
