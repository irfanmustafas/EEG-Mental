function Pwr = GetPwr256(dPath)

Pwr = [];
RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = Fs;                       % 256
TF.frange   = [2 50];
nWin        = fix(TF.tWin*TF.Fs);       %nWin�� Fs�� ����(0.05)�� ����, 128
nShift      = fix(TF.tShift*TF.Fs);     %nShift�� Fs�� 1/10(0.1)�� ������ ����, 25
nFFT        = 2^nextpow2(nWin);     %nWin�� ���� ����� 2�� �ŵ����� �� ���ϱ�