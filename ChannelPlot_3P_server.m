close all; clear; clc;


RAW_DIR  = '../Raw/';
REP_DIR  = '../Rep/';

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


oFs      = 256;     % ���� Sampling Rate
Fs       = 256;     % ��ȯ�� Sampling Rate
elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);

% grpPwr ���� ������ 2G�� �Ѿ ���� �ε�
% load('TgrpPwr.mat','grpPwr','WT','elocs','nFr','nTm','nCh','chName');
load('grpInfo.mat','WT','elocs','nFr','nTm','nCh','chName');
load('grpPwr.mat','grpPwr');




%%
ch_tick        = 1:nCh;
tm_tick        = [10 320 630 940 1250 1570];
p_color        = [1 1 1; 1 0 0];
x_tick_label   = cell(length(tm_tick),2);
% % tm_tick�� ��� �ִ� 320, 630, 940, 1250, 1560 �ʰ� WT.time�� �ش��ϴ� index�� ����
for t = 1:length(tm_tick)
   [~,I]             = min(abs(WT.time-tm_tick(t)));
   x_tick_label{t,1} = I;
   x_tick_label{t,2} = num2str(tm_tick(t),'%3.1f');
end
x_tick         = cell2mat(x_tick_label(:,1));
x_tick_label   = x_tick_label(:,2);
y_tick         = ch_tick;
y_tick_label   = chName;

% ���� ����
gm_freq  = (WT.freq >= 30) & (WT.freq <= 50);
mu_alpha_freq  = (WT.freq >= 8) & (WT.freq < 12);
beta_freq = (WT.freq >= 12) & (WT.freq < 25);
theta_freq = (WT.freq >= 4) & (WT.freq < 8);

%% gamma ����
f2_1 = figure('NumberTitle', 'off', 'Name', 'Gamma 30~50');
gmPwr    = cellfun(@(x) squeeze(nanmean(x(:,gm_freq,:,:),2)),grpPwr(:,2),'uniformoutput',0);
% gmPwr�� �� ���� �׷캰�� nCh x nTm x nSub ����, �׷캰 ������ ���� �ٸ��� nSub ���� �ٸ�
% grp1 �����, grp2 ��Ȳ���, grp3 ����
grp1  = gmPwr{1,:};  grp1 = permute(grp1,[3 1 2]); % nSub x nCh x nTm
grp2  = gmPwr{2,:};  grp2 = permute(grp2,[3 1 2]);
grp3  = gmPwr{3,:};  grp3 = permute(grp3,[3 1 2]);


set(gcf,'position', [200 100 1500 800]);     % ��ġ �� ũ�� ����

% 1�ʿ� 1.6�� ��迡 �� ������ index
% [~,xt1]             = min(abs(WT.time-1.0));
% [~,xt2]             = min(abs(WT.time-1.6));


Pinterval = 1:nTm;

subplot(3,1,1); %Fp1
ch = 1;
grp11_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp21_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp31_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp11_av); plot(grp21_av); plot(grp31_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
legend('Depression', 'Panic', 'Normal');
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);

subplot(3,1,2); %Fp2
ch = 2;
grp12_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp22_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp32_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp12_av); plot(grp22_av); plot(grp32_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);



subplot(3,1,3); %Fp1 - Fp2
grp1d_av = grp11_av - grp12_av;
grp2d_av = grp21_av - grp22_av;
grp3d_av = grp31_av - grp32_av;
hold on;
plot(grp1d_av); plot(grp2d_av); plot(grp3d_av);
shading flat;
hold off;
title('Fp1 - Fp2','fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����


%% mu_alpha ����
f2_2 = figure('NumberTitle', 'off', 'Name', 'Mu_Alpah 8~12');
mu_alphaPwr    = cellfun(@(x) squeeze(nanmean(x(:,mu_alpha_freq,:,:),2)),grpPwr(:,2),'uniformoutput',0);
% gmPwr�� �� ���� �׷캰�� nCh x nTm x nSub ����, �׷캰 ������ ���� �ٸ��� nSub ���� �ٸ�
% grp1 �����, grp2 ��Ȳ���, grp3 ����
grp1  = mu_alphaPwr{1,:};  grp1 = permute(grp1,[3 1 2]); % nSub x nCh x nTm
grp2  = mu_alphaPwr{2,:};  grp2 = permute(grp2,[3 1 2]);
grp3  = mu_alphaPwr{3,:};  grp3 = permute(grp3,[3 1 2]);


set(gcf,'position', [200 100 1500 800]);     % ��ġ �� ũ�� ����


Pinterval = 1:nTm;

subplot(3,1,1); %Fp1
ch = 1;
grp11_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp21_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp31_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp11_av); plot(grp21_av); plot(grp31_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
legend('Depression', 'Panic', 'Normal');
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);

subplot(3,1,2); %Fp2
ch = 2;
grp12_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp22_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp32_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp12_av); plot(grp22_av); plot(grp32_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);



subplot(3,1,3); %Fp1 - Fp2
grp1d_av = grp11_av - grp12_av;
grp2d_av = grp21_av - grp22_av;
grp3d_av = grp31_av - grp32_av;
hold on;
plot(grp1d_av); plot(grp2d_av); plot(grp3d_av);
shading flat;
hold off;
title('Fp1 - Fp2','fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����





%% Beta ����
f2_3 = figure('NumberTitle', 'off', 'Name', 'Beta 12~25');
betaPwr    = cellfun(@(x) squeeze(nanmean(x(:,beta_freq,:,:),2)),grpPwr(:,2),'uniformoutput',0);
% gmPwr�� �� ���� �׷캰�� nCh x nTm x nSub ����, �׷캰 ������ ���� �ٸ��� nSub ���� �ٸ�
% grp1 �����, grp2 ��Ȳ���, grp3 ����
grp1  = betaPwr{1,:};  grp1 = permute(grp1,[3 1 2]); % nSub x nCh x nTm
grp2  = betaPwr{2,:};  grp2 = permute(grp2,[3 1 2]);
grp3  = betaPwr{3,:};  grp3 = permute(grp3,[3 1 2]);


set(gcf,'position', [200 100 1500 800]);     % ��ġ �� ũ�� ����


Pinterval = 1:nTm;

subplot(3,1,1); %Fp1
ch = 1;
grp11_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp21_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp31_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp11_av); plot(grp21_av); plot(grp31_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
legend('Depression', 'Panic', 'Normal');
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);

subplot(3,1,2); %Fp2
ch = 2;
grp12_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp22_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp32_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp12_av); plot(grp22_av); plot(grp32_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);



subplot(3,1,3); %Fp1 - Fp2
grp1d_av = grp11_av - grp12_av;
grp2d_av = grp21_av - grp22_av;
grp3d_av = grp31_av - grp32_av;
hold on;
plot(grp1d_av); plot(grp2d_av); plot(grp3d_av);
shading flat;
hold off;
title('Fp1 - Fp2','fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����





%% Theta ����
f2_4 = figure('NumberTitle', 'off', 'Name', 'Theta 4~8');
thetaPwr    = cellfun(@(x) squeeze(nanmean(x(:,theta_freq,:,:),2)),grpPwr(:,2),'uniformoutput',0);
% gmPwr�� �� ���� �׷캰�� nCh x nTm x nSub ����, �׷캰 ������ ���� �ٸ��� nSub ���� �ٸ�
% grp1 �����, grp2 ��Ȳ���, grp3 ����
grp1  = thetaPwr{1,:};  grp1 = permute(grp1,[3 1 2]); % nSub x nCh x nTm
grp2  = thetaPwr{2,:};  grp2 = permute(grp2,[3 1 2]);
grp3  = thetaPwr{3,:};  grp3 = permute(grp3,[3 1 2]);


set(gcf,'position', [200 100 1500 800]);     % ��ġ �� ũ�� ����


Pinterval = 1:nTm;

subplot(3,1,1); %Fp1
ch = 1;
grp11_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp21_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp31_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp11_av); plot(grp21_av); plot(grp31_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
legend('Depression', 'Panic', 'Normal');
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);

subplot(3,1,2); %Fp2
ch = 2;
grp12_av = mean(squeeze(grp1(:,ch,Pinterval))',2);
grp22_av = mean(squeeze(grp2(:,ch,Pinterval))',2);
grp32_av = mean(squeeze(grp3(:,ch,Pinterval))',2);
hold on;
plot(grp12_av); plot(grp22_av); plot(grp32_av);
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
title(chName{ch,1},'fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);



subplot(3,1,3); %Fp1 - Fp2
grp1d_av = grp11_av - grp12_av;
grp2d_av = grp21_av - grp22_av;
grp3d_av = grp31_av - grp32_av;
hold on;
plot(grp1d_av); plot(grp2d_av); plot(grp3d_av);
shading flat;
hold off;
title('Fp1 - Fp2','fontname','times','fontsize',12);
set(gca,'xtick',x_tick,'xticklabel',x_tick_label);    % x�� �� ����
