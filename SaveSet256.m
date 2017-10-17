function [] = SaveSet256(dPath)
RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

oFs      = 256;     % ���� Sampling Rate
Fs       = 256;     % ��ȯ�� Sampling Rate
elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

LowF     = 0;
HighF    = 55;
EEG      = pop_loadset('sample.set');

txt_name    = [RAW_DIR dPath '/EEG-1.txt'];
ch1         = dlmread(txt_name);
ch1(:,1) = [];
txt_name    = [RAW_DIR dPath '/EEG-2.txt'];
ch2         = dlmread(txt_name);
ch2(:,1) = [];
data = [ch1'; ch2'];

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
%%%%% LPF for EEG channels
ld_LPF      = fdesign.lowpass('N,Fp,Fst',250,HighF,HighF+2,Fs);
Ld_LPF      = design(ld_LPF,'firls');
fprintf('LPF...\n');
for n = 1:size(EEG.data,1)
    EEG.data(n,:)  = filtfilt(Ld_LPF.Numerator,1,double(EEG.data(n,:)));
end

pop_saveset(EEG, 'filename', dPath, 'filepath', REP_DIR);