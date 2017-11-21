function lines = SaveSet2048(dPath, nCh, TF, elocs)
RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

oFs      = TF.Fs;     % 원래 Sampling Rate
Fs       = 256;     % 변환할 Sampling Rate

% E가 붙은 경로가 존재하지 않는 경우 떼고 읽어오게 설정
if 7 ~= exist([RAW_DIR dPath], 'dir')
    dPath = dPath(2:end);
    disp(['[Detected] ' dPath])
end

txt_name    = [RAW_DIR dPath '/EEG-1.txt'];
ch1         = dlmread(txt_name);
ch1(:,1) = [];
txt_name    = [RAW_DIR dPath '/EEG-2.txt'];
ch2         = dlmread(txt_name);
ch2(:,1) = [];
data = [ch1'; ch2'];

if dPath(1) ~= 'E'
    dPath = ['E' dPath];
end

EEG      = pop_loadset('sample.set');
EEG.setname = dPath;
EEG.data    = data;
EEG.pnts    = size(EEG.data,2);
EEG.times   = 0:1/oFs:(length(data)/oFs)-(1/oFs);
EEG.srate   = oFs;
EEG.nbchan  = nCh;
EEG.xmin    = EEG.times(1);
EEG.xmax    = EEG.times(end);
EEG.chanlocs = elocs;
EEG         = eeg_checkset(EEG);

%%%% down sampling oFs(2048) -> Fs(256)
EEG         = pop_resample(EEG,Fs);
HighF       = TF.frange(2);

%%%%% Low Pass Filter for EEG channels
%     Ap    - Passband Ripple (dB)
%     Ast   - Stopband Attenuation (dB)
%     F3dB  - 3dB Frequency
%     Fc    - Cutoff Frequency
%     Fp    - Passband Frequency
%     Fst   - Stopband Frequency
%     N     - Filter Order
%     Nb    - Numerator Order
%     Na    - Denominator Order
ld_LPF      = fdesign.lowpass('N,Fp,Fst',250,HighF,HighF+2,Fs);
Ld_LPF      = design(ld_LPF,'firls');
fprintf('LPF...\n');
for n = 1:size(EEG.data,1)
    EEG.data(n,:)  = filtfilt(Ld_LPF.Numerator,1,double(EEG.data(n,:)));
end

pop_saveset(EEG, 'filename', dPath, 'filepath', REP_DIR);
lines = length(data);