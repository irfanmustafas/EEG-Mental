close all; clear; clc;


RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

% 1: Depression, 2: Panic, 3: Normal
subInfo  = {
    'E003-2', 1;
    'E003-3', 1;
    'E003-4', 1;
    'E003-5', 1;
    'E004-2', 1;
    'E004-3', 1;
    'E004-4', 1;
    'E004-5', 1;
    'E007-2', 1;
    'E007-3', 1;
    'E007-4', 1;
    'E007-5', 1;
    'E008-1', 1;
    'E008-2', 1;
    'E008-3', 1;
    'E008-4', 1;
    'E008-5', 1;
    'E009-1', 1;
    'E009-2', 1;
    'E009-3', 1;
    'E009-4', 1;
    'E009-5', 1;
    'E010-1', 1;
    'E010-2', 1;
    'E010-3', 1;
    'E010-4', 1;
    'E010-5', 1;
    'E012-1', 2;
    'E012-2', 2;
    'E012-3', 2;
    'E012-4', 2;
    'E012-5', 2;
    'E013-1', 2;
    'E013-2', 2;
    'E013-3', 2;
    'E013-4', 2;
    'E013-5', 2;
    'E014-1', 1;
    'E014-2', 1;
    'E014-3', 1;
    'E014-4', 1;
    'E014-5', 1;
    'E016-1', 2;
    'E016-2', 2;
    'E016-3', 2;
    'E016-4', 2;
    'E016-5', 2;
    'E017-1', 2;
    'E017-2', 2;
    'E017-3', 2;
    'E017-4', 2;
    'E017-5', 2;
    'E018-1', 2;
    'E018-2', 2;
    'E018-3', 2;
    'E018-4', 2;
    'E018-5', 2;
    'E019-1', 1;
    'E019-2', 1;
    'E019-3', 1;
    'E019-4', 1;
    'E019-5', 1;
    'E020-1', 2;
    'E020-2', 2;
    'E020-3', 2;
    'E020-4', 2;
    'E020-5', 2;
    'E021-1', 2;
    'E021-2', 2;
    'E021-3', 2;
    'E021-4', 2;
    'E021-5', 2;
    'E022-1', 3;
    'E022-2', 3;
    'E022-3', 3;
    'E022-4', 3;
    'E022-5', 3;
    'E023-1', 3;
    'E023-2', 3;
    'E023-3', 3;
    'E023-4', 3;
    'E023-5', 3;
    'E024-1', 3;
    'E024-2', 3;
    'E024-3', 3;
    'E024-4', 3;
    'E024-5', 3;
    'E025-1', 3;
    'E025-2', 3;
    'E025-3', 3;
    'E025-4', 3;
    'E025-5', 3;
    'E026-1', 3;
    'E026-2', 3;
    'E026-3', 3;
    'E026-4', 3;
    'E026-5', 3;
    'E028-1', 3;
    'E028-2', 3;
    'E028-3', 3;
    'E028-4', 3;
    'E028-5', 3;
    'E029-1', 2;
    'E029-2', 2;
    'E029-3', 2;
    'E029-4', 2;
    'E029-5', 2;
    'E030-1', 3;
    'E030-2', 3;
    'E030-3', 3;
    'E030-4', 3;
    'E030-5', 3;
    };


for n = 1:length(subInfo)
    name = subInfo{n,1};
    switch name(6)
        case '1'
            subInfo{n,3} = 1;
        case '2'
            subInfo{n,3} = 2;
        case '3'
            subInfo{n,3} = 3;
        case '4'
            subInfo{n,3} = 4;
        case '5'
            subInfo{n,3} = 5;
    end
end



nSub     = size(subInfo,1);
group    = unique(cell2mat(subInfo(:,2)));
nGRP     = length(group);
ngrp     = zeros(nGRP,2);
for g = 1:nGRP
    ngrp(g,1)   = group(g);
    ngrp(g,2)   = sum(cell2mat(subInfo(:,2))==group(g));
end


oFs      = 256;     % 원래 Sampling Rate
Fs       = 256;     % 변환할 Sampling Rate
elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);




%%
LowF     = 1;
HighF    = 50;
EEG      = pop_loadset('sample.set');


for s = 1:nSub
    sub_name    = subInfo{s,1};
    
    txt_name    = [RAW_DIR sub_name '/EEG-1.txt'];
    ch1         = dlmread(txt_name);
    ch1(:,1) = [];
    txt_name    = [RAW_DIR sub_name '/EEG-2.txt'];
    ch2         = dlmread(txt_name);
    ch2(:,1) = [];
    dat = [ch1'; ch2'];
    
    EEG.setname = sub_name;
    EEG.data    = dat;
    EEG.pnts    = size(EEG.data,2);
    EEG.times   = 0:1/oFs:length(dat)-(1/oFs);
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
    
    pop_saveset(EEG, 'filename', sub_name, 'filepath', REP_DIR);
end

%%

TF.tWin     = 0.50;
TF.tShift   = 0.10;
TF.Fs       = Fs;                       % 256
TF.frange   = [2 50];
nWin        = fix(TF.tWin*TF.Fs);       %nWin은 Fs의 절반(0.05)로 설정, 128
nShift      = fix(TF.tShift*TF.Fs);     %nShift는 Fs의 1/10(0.1)의 정수로 설정, 25
nFFT        = 2^nextpow2(nWin);     %nWin과 가장 가까원 2의 거듭제곱 수 구하기

%grp_idx는 총 그룹 종류 할당
grp_idx     = unique(cell2mat(subInfo(:,2)));
%nGp는 각 그룹의 갯수 저장
nGp         = zeros(length(grp_idx),1);
for g = 1:length(grp_idx)
    nGp(g,1)    = sum(cellfun(@(x) x==grp_idx(g),subInfo(:,2)));
end

subPwr      = cell(length(grp_idx),1);
for s = 1:nSub
    sub_name    = subInfo{s,1};
    sub_grp     = subInfo{s,2};
    set_name    = [sub_name '.set'];
    EEG         = pop_loadset('filepath', REP_DIR, 'filename', set_name);
    
    % [S,F,T,P] = spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs)
    [S,F,T,P]   = spectrogram(double(EEG.data(1,:)),nWin,nWin-nShift,nFFT,Fs);
    f_idx       = (F>=TF.frange(1)) & (F<=TF.frange(2)); % 2~50만 쳐냄 -> 25개
    F           = F(f_idx);
    TF.freq     = F;     nFr   = length(F);
    TF.time     = T;     nTm   = length(T);
    
    specPwr     = zeros(nCh,nFr,nTm);
    
    for ch = 1:nCh
        [S,F,T,P]= spectrogram(double(EEG.data(ch,:)),nWin,nWin-nShift,nFFT,Fs);
        P           = P(f_idx,:);
        specPwr(ch,:,:)  = P;
    end
    subPwr{sub_grp,1} = cat(4,subPwr{sub_grp,1},specPwr);
end
save([REP_DIR 'sub_spectrogram.mat'],'subPwr','TF');


%%

load([REP_DIR 'sub_spectrogram.mat']);
grp_idx     = unique(cell2mat(subInfo(:,2)));
nGp         = zeros(length(grp_idx),1);
for g = 1:length(grp_idx)
    nGp(g,1)    = sum(cellfun(@(x) x==grp_idx(g),subInfo(:,2)));
end
nFr      = length(TF.freq);
nTm      = length(TF.time);

% Fp1, Fp2
ch_fp1    = find(strcmp(chName,'Fp1'));  ch_fp2 = find(strcmp(chName,'Fp2'));
frontal_pwr   = cell(length(grp_idx),3);   % 1:Fp1, 2:Fp2
for g = 1:length(grp_idx)
    fp1       = cellfun(@(x) squeeze(x(ch_fp1,:,:,:)),subPwr(g,1),'uniformoutput',0);
    fp2       = cellfun(@(x) squeeze(x(ch_fp2,:,:,:)),subPwr(g,1),'uniformoutput',0);
    
    frontal_pwr{g,1}  = cell2mat(fp1);
    frontal_pwr{g,2}  = cell2mat(fp2);
    % Fp1과 Fp2의 차이 값을 3번째에 저장
    frontal_pwr{g,3}  = cell2mat(fp1)-cell2mat(fp2);
end

% [320 630 940 1250 1560] 초단위 경계
x_tick   = [min(find(320 <= TF.time & TF.time < 321)) ...
    min(find(630 <= TF.time & TF.time < 631)) ...
    min(find(940 <= TF.time & TF.time < 941)) ...
    min(find(1250 <= TF.time & TF.time < 1251)) ...
    min(find(1560 <= TF.time & TF.time < 1561))];
x_tick_label   = num2cell(fix(TF.time(x_tick)));
y_tick   = 1:4:nFr;     y_tick_label   = num2cell(flipud(round(TF.freq(y_tick))));

figure;
for g = 1:length(grp_idx)
    %   그룹이 3개라서 조절
    %   subplot(2,2,g);
    subplot(3,1,g);
    % 그룹별로 Fp1과 Fp2의 차이 값의 평균을 spectrogram으로 그림
    % imagesc(flipud(frontal_pwr{g,1}));  colormap(jet); caxis([-10 10]); colorbar();
    % imagesc(flipud(frontal_pwr{g,1}));  colormap(jet); colorbar();
    imagesc(flipud(mean(frontal_pwr{g,1},3)));  colormap(jet); caxis([-10 10]); colorbar();
    
    set(gca,'xtick',x_tick,'xticklabel',x_tick_label);
    set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
    
    switch g
        case 1
            ylabel('Depression');
        case 2
            ylabel('Panic');
        case 3
            ylabel('Healthy');
    end
end
subplot(3,1,1); title(gca, 'Fp1');

figure;
for g = 1:length(grp_idx)
    subplot(3,1,g);
    % imagesc(flipud(frontal_pwr{g,2}));  colormap(jet); caxis([-10 10]); colorbar();
    % imagesc(flipud(frontal_pwr{g,2}));  colormap(jet); colorbar();
    imagesc(flipud(mean(frontal_pwr{g,2},3)));  colormap(jet); caxis([-10 10]); colorbar();
    
    set(gca,'xtick',x_tick,'xticklabel',x_tick_label);
    set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
    
    switch g
        case 1
            ylabel('Depression');
        case 2
            ylabel('Panic');
        case 3
            ylabel('Healthy');
    end
end
subplot(3,1,1); title(gca, 'Fp2');

figure;
for g = 1:length(grp_idx)
    subplot(3,1,g);
    % imagesc(flipud(frontal_pwr{g,3}));  colormap(jet); caxis([-10 10]); colorbar();
    % imagesc(flipud(frontal_pwr{g,3}));  colormap(jet); colorbar();
    imagesc(flipud(mean(frontal_pwr{g,3},3)));  colormap(jet); caxis([-10 10]); colorbar();
    
    set(gca,'xtick',x_tick,'xticklabel',x_tick_label);
    set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
    
    switch g
        case 1
            ylabel('Depression');
        case 2
            ylabel('Panic');
        case 3
            ylabel('Healthy');
    end
end
subplot(3,1,1); title(gca, 'Fp1 - Fp2');




msTime = length(ch1)/Fs*1000;

spec_freq   = [0 55];
WT.width    = 5;
WT.gwidth   = 3;
WT.freq     = spec_freq(1):1:spec_freq(2);
WT.time     = (0:20:(msTime-1/Fs))*0.001;
WT.fs       = 1/(WT.time(2)-WT.time(1));
nFr         = length(WT.freq);
nTm         = length(WT.time);

grpPwr      = cell(nGRP,2);
grpPwr(:,1) = num2cell(group);
for s = 1:nSub
   sub_name    = subInfo{s,1};
   sub_grp     = subInfo{s,2};
   set_name    = [sub_name '.set'];
   EEG         = pop_loadset('filepath', REP_DIR,'filename', set_name);
   chPwr       = zeros(nCh,nFr,nTm,'single');       %4차원 정의, 채널xBandx시간x인원수
   for ch = 1:nCh
      [spectrum,~,~]    = ft_specest_wavelet(double(EEG.data(ch,:)), WT.time, 'verbose',0, ...
         'freqoi',WT.freq,'timeoi',WT.time,'width',WT.width,'gwidth',WT.gwidth);
      chPwr(ch,:,:)     = single(10*log10(abs(squeeze(spectrum))));
   end
   grpPwr{sub_grp,2}    = cat(4,grpPwr{sub_grp,2},chPwr);   %chPwr가 4차원임으로
end

% grpPwr 용량이 2G를 넘어서 별도 저장
% save('TgrpPwr.mat','grpPwr','WT','elocs','nFr','nTm','nCh','chName');
save('grpInfo.mat','WT','elocs','nFr','nTm','nCh','chName');
save('grpPwr.mat','grpPwr', '-v7.3')