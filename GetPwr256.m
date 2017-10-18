function Pwr = GetPwr256(dPath, nCh)

Pwr = [];
REP_DIR  = './Rep/';

TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = Fs;                       % 256
TF.frange   = [0 55];                   % 0~55 Hz ����
nWin        = fix(TF.tWin*TF.Fs);       % nWin�� Fs�� ����(0.05)�� ����, 128
nShift      = fix(TF.tShift*TF.Fs);     % nShift�� Fs�� 1/10(0.1)�� ������ ����, 25
nFFT        = 2^nextpow2(nWin);         % nWin�� ���� ����� 2�� �ŵ����� �� ���ϱ�

set_name = [dPath '.set'];
EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);

% F�� ���� �Ҵ� ���� �ѹ� ���� ���� -> �ߺ��Ǵ� ���� ��� ã�ƺ��� �͵�
[S,F,T,P]   = spectrogram(double(EEG.data(1,:)),nWin,nWin-nShift,nFFT,Fs);
f_idx       = (F>=TF.frange(1)) & (F<=TF.frange(2));    % Frequencey �ĳ���
F           = F(f_idx);
TF.freq     = F;     nFr   = length(F);
TF.time     = T;     nTm   = length(T);
% 0~55 Hz �ش��ϴ� Frequencey�� �ĳ�, ������ �� ������ �ƴϰ� +/- 1 ���� ��.
% F���� ������ ����� 0, 1.953125, 3.90625, 5.859375, 7.81250 ... ����

specPwr     = zeros(nCh,nFr,nTm);
% nFr�� 0~55 ���̿� �ش��ϴ� Frequency ��, nTm�� Window ���� �ð�

for ch = 1:nCh
    [S,F,T,P]= spectrogram(double(EEG.data(ch,:)),nWin,nWin-nShift,nFFT,Fs);
    P           = P(f_idx,:);
    specPwr(ch,:,:)  = P;
end
subPwr{sub_grp,1} = cat(4,subPwr{sub_grp,1},specPwr);

ch1 = 1;    ch2 = 2;