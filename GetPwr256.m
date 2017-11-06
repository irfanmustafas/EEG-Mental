function Pwr = GetPwr256(dPath, nCh, TF)

REP_DIR  = './Rep/';
nFr   = length(TF.freq);
nTm   = length(TF.time);
set_name = [dPath '.set'];
EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);

Pwr     = zeros(nCh,nFr,nTm);
% nFr�� 0~55 ���̿� �ش��ϴ� Frequency ��, nTm�� Window ���� �ð�

for ch = 1:nCh
    [S,F,T,P]   = spectrogram(double(EEG.data(ch,:)),TF.nWin,TF.nWin-TF.nShift,TF.nFFT,TF.Fs);
    P           = P(TF.f_idx,:);
    Pwr(ch,:,:) = P;
end