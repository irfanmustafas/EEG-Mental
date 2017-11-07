function Wav = GetWav256(dPath, nCh, WT)

REP_DIR  = './Rep/';
nFr   = WT.nFr;
nTm   = WT.nTm;
set_name = [dPath '.set'];
EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);

Wav       = zeros(nCh,nFr,nTm,'single');
% nFr은 0~55 사이에 해당하는 Frequency 값, nTm은 Window 기준 시간

for ch = 1:nCh
    [spectrum,~,~]    = ft_specest_wavelet(double(EEG.data(ch,:)), WT.time, 'verbose',0, ...
                        'freqoi',WT.freq,'timeoi',WT.time,'width',WT.width,'gwidth',WT.gwidth);
    Wav(ch,:,:)     = single(10*log10(abs(squeeze(spectrum))));
end