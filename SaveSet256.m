function [] = SaveSet256(dPath, nCh)
RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

oFs      = 256;     % ���� Sampling Rate
Fs       = 256;     % ��ȯ�� Sampling Rate

txt_name    = [RAW_DIR dPath '/EEG-1.txt'];
ch1         = dlmread(txt_name);
ch1(:,1) = [];
txt_name    = [RAW_DIR dPath '/EEG-2.txt'];
ch2         = dlmread(txt_name);
ch2(:,1) = [];
data = [ch1'; ch2'];

EEG      = pop_loadset('sample.set');
EEG.setname = dPath;
EEG.data    = data;
EEG.pnts    = size(EEG.data,2);
EEG.times   = 0:1/oFs:length(data)-(1/oFs);
EEG.srate   = oFs;
EEG.nbchan  = nCh;
EEG.xmin    = EEG.times(1);
EEG.xmax    = EEG.times(end);
EEG.chanlocs = elocs;
EEG         = eeg_checkset(EEG);

%%%% down sampling oFs (256)->Fs(256)
EEG         = pop_resample(EEG,Fs);

% Low Pass Filter
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