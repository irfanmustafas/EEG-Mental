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


oFs      = 256;     % 원래 Sampling Rate
Fs       = 256;     % 변환할 Sampling Rate
elocs    = readlocs('Standard-10-20-Cap2.locs');
chName   = {elocs.labels}';
nCh      = length(chName);








load('TgrpPwr.mat','grpPwr','WT','elocs','nFr','nTm','nCh','chName');
% 시간을 1~1.6초 구간만 잘라서 topography 그리기 (gmPwr은 앞에서 이미 gamma만 추출된 상태)
% WT변수는 TgrpPwr.mat 파일에 저장되어 있던 것 읽어옴
roi_time    = [1.0 1.6];
roi_idx     = (WT.time>=roi_time(1)) & (WT.time <= roi_time(2));
rgmPwr      = cellfun(@(x) squeeze(nanmean(x(:,roi_idx,:),2))',gmPwr,'uniformoutput',0);
grp2        = rgmPwr{2,:};  % nSub (14) x nCh (28), nTm (150) 차원 통합됨
grp4        = rgmPwr{4,:};  % nSub (14) x nCh (28), nTm (150) 차원 통합됨


