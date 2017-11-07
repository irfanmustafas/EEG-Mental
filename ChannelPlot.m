close all; clear; clc;


RAW_DIR  = '../Raw/';
REP_DIR  = '../Rep/';

% 1: Depression, 2: Panic, 3: Normal
subInfo  = { 'E019-5', 1;
             'E021-5', 2;
             'E022-5', 3;
};


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








load('TgrpPwr.mat','grpPwr','WT','elocs','nFr','nTm','nCh','chName');
ch_tick        = 1:nCh;
tm_tick        = [0 1 2 3];
p_color        = [1 1 1; 1 0 0];
x_tick_label   = cell(length(tm_tick),2);
for t = 1:length(tm_tick)
   [~,I]             = min(abs(WT.time-tm_tick(t)));
   x_tick_label{t,1} = I;
   x_tick_label{t,2} = num2str(tm_tick(t),'%3.1f');
end
x_tick         = cell2mat(x_tick_label(:,1));
x_tick_label   = x_tick_label(:,2);
y_tick         = ch_tick;
y_tick_label   = chName;

% gamma ������ ����
gm_freq  = (WT.freq >= 30) & (WT.freq <= 50);
% gm_freq  = (WT.freq >= 20) & (WT.freq < 30);

gmPwr    = cellfun(@(x) squeeze(nanmean(x(:,gm_freq,:,:),2)),grpPwr(:,2),'uniformoutput',0);
grp1  = gmPwr{1,:};  grp1 = permute(grp1,[3 1 2]); % nSub x nCh x nTm
grp2  = gmPwr{2,:};  grp2 = permute(grp2,[3 1 2]);
grp3  = gmPwr{3,:};  grp3 = permute(grp3,[3 1 2]);


f2_1 = figure;
set(gcf,'position', [200 100 1500 800]);     % ��ġ �� ũ�� ����

% 1�ʿ� 1.6�� ��迡 �� ������ index
[~,xt1]             = min(abs(WT.time-1.0));
[~,xt2]             = min(abs(WT.time-1.6));

tm_tick2        = [0 1 1.6 2 3];
x_tick_label2   = cell(length(tm_tick2),2);

% % tm_tick2�� ��� �ִ� 0, 1, 1.6 2, 3 �ʰ� WT.time�� �ش��ϴ� index�� ����
% for t = 1:length(tm_tick2)
%    [~,I]             = min(abs(WT.time-tm_tick2(t)));
%    x_tick_label2{t,1} = I;
%    x_tick_label2{t,2} = num2str(tm_tick2(t),'%3.1f');
% end
% 
% x_tick2         = cell2mat(x_tick_label2(:,1));
% x_tick_label2   = x_tick_label2(:,2);

subplot(2,1,1);
ch = 1;
grp1_av = mean(squeeze(grp1(:,ch,4:800))',1);
grp2_av = mean(squeeze(grp2(:,ch,4:800))',1);
grp3_av = mean(squeeze(grp3(:,ch,4:800))',1);
hold on;
plot(grp1_av); plot(grp2_av); plot(abs(grp3_av));
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
% title(chName{ch,1},'fontname','times','fontsize',12);
% set(gca,'xtick',x_tick2,'xticklabel',x_tick_label2);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);

subplot(2,1,2);
ch = 2;
grp1_av = mean(squeeze(grp1(:,ch,4:800))',1);
grp2_av = mean(squeeze(grp2(:,ch,4:800))',1);
grp3_av = mean(squeeze(grp3(:,ch,4:800))',1);
hold on;
plot(grp1_av); plot(grp2_av); plot(abs(grp3_av));
shading flat;
hold off;
% h1 = line([xt1 xt1], [0 15]);   % �տ� �� �߱�
% h2 = line([xt2 xt2], [0 15]);   % �ڿ� �� �߱�
% set([h1 h2],'Color','k','LineWidth',1)  % �� ���� �� �α� ����
% patch([xt1 xt2 xt2 xt1],[0 0 15 15],'k','FaceAlpha',.3) % ��� ȸ�� ĥ�ϱ�
% set(gca,'children',flipud(get(gca,'children'))) % �׷��� ��� �ڿ� ������ �� �ٽ� ĥ�ϱ�
% hold off;
% title(chName{ch,1},'fontname','times','fontsize',12);
% set(gca,'xtick',x_tick2,'xticklabel',x_tick_label2);    % x�� �� ����
% p = gca;    % x�� �� �Ӽ� �ٽ� ������
% p.XTickLabel = {x_tick_label2{1},['\bf ' x_tick_label2{2}],['\bf ' x_tick_label2{3}], x_tick_label2{4}, x_tick_label2{5}};
% % x�� �󺧿��� �ι�°�� ����° ����
% % ylim([0 15]);   % y�� ��� �� 0~15�� ����
% %set(gca,'ytick',y_tick,'yticklabel',y_tick_label);
% colormap(p_color);
