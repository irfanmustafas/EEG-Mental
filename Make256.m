close all; clear; clc;

RAW_DIR  = '../data/';
REP_DIR  = './Rep/';

load('S256.mat');

pSize = size(Sinfo);
iID = 1; iSym = 2; iGen = 3; iAge = 4; iHav = 10; iDO = 12;
dPath = '';

for p = 1:pSize(1)
    if Sinfo(p, iDO), continue, end
    
    cLimit = Sinfo(p,iHav);
    if cLimit == 0, qLimit = 5;
    else qLimit = cLimit - 1; end
    
    pID = Sinfo(p,iID); pSym = Sinfo(p,iSym); pGen = Sinfo(p,iGen); pAge = Sinfo(p,iAge);
    
    for q = 1:qLimit
        pVst = q;
        dPath = sprintf('E%03d-%d',Sinfo(p,iID),q);
        disp(dPath);
    end
end
