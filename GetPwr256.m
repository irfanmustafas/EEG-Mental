function Pwr = GetPwr256(dPath)

Pwr = [];
RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = Fs;                       % 256
TF.frange   = [0 55];                   % 0~55 Hz 범위
nWin        = fix(TF.tWin*TF.Fs);       %nWin은 Fs의 절반(0.05)로 설정, 128
nShift      = fix(TF.tShift*TF.Fs);     %nShift는 Fs의 1/10(0.1)의 정수로 설정, 25
nFFT        = 2^nextpow2(nWin);     %nWin과 가장 가까원 2의 거듭제곱 수 구하기

set_name = [dPath '.set'];
EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);