function Pwr = GetPwr256(dPath, nCh)

Pwr = [];
REP_DIR  = './Rep/';

TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = Fs;                       % 256
TF.frange   = [0 55];                   % 0~55 Hz 범위
nWin        = fix(TF.tWin*TF.Fs);       % nWin은 Fs의 절반(0.05)로 설정, 128
nShift      = fix(TF.tShift*TF.Fs);     % nShift는 Fs의 1/10(0.1)의 정수로 설정, 25
nFFT        = 2^nextpow2(nWin);         % nWin과 가장 가까운 2의 거듭제곱 수 구하기

set_name = [dPath '.set'];
EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);

% F값 범위 할당 위해 한번 먼저 실행 -> 중복되니 줄일 방법 찾아보는 것도
[S,F,T,P]   = spectrogram(double(EEG.data(1,:)),nWin,nWin-nShift,nFFT,Fs);
f_idx       = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey 쳐내기
F           = F(f_idx);
TF.freq     = F;     nFr   = length(F);
TF.time     = T;     nTm   = length(T);
% 0~55 Hz 해당하는 Frequencey만 쳐냄, 범위의 딱 절반은 아니고 +/- 1 정도 됨.
% F값을 실제로 열어보면 0, 1.953125, 3.90625, 5.859375, 7.81250 ... 순서

specPwr     = zeros(nCh,nFr,nTm);
% nFr은 0~55 사이에 해당하는 Frequency 값, nTm은 Window 기준 시간

for ch = 1:nCh
    [S,F,T,P]= spectrogram(double(EEG.data(ch,:)),nWin,nWin-nShift,nFFT,Fs);
    P           = P(f_idx,:);
    specPwr(ch,:,:)  = P;
end
subPwr{sub_grp,1} = cat(4,subPwr{sub_grp,1},specPwr);

ch1 = 1;    ch2 = 2;