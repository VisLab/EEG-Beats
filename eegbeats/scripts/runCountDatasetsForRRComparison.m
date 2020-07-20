%% Summarize how many datasets had valid first blocks for EEG-Beats and PNC.

%% Set the input compare file name
%compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2/EBPNCCompare.mat';
compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2/EBPNCCompareWithRemoval.mat';

%% Load the compare file
temp = load(compareFile);
compareInfo = temp.compareInfo;

%% Now do the counts
totalBoth = 0;
totalPNCOnly = 0;
totalEBOnly = 0;
for k = 1:length(compareInfo)
    EBMask = compareInfo(k).EBMask;
    PNCMask = compareInfo(k).PNCMask;
    both = sum(EBMask & PNCMask);
    PNCOnly = sum(PNCMask & ~EBMask);
    EBOnly = sum(EBMask & ~PNCMask);
    fprintf('%s %s: Both:%d, PNCOnly:%d, EBOnly:%d\n', ...
        compareInfo(k).EBName, compareInfo(k).PNCName, ...
        both, PNCOnly, EBOnly);
    totalBoth = totalBoth + both;
    totalPNCOnly = totalPNCOnly + PNCOnly;
    totalEBOnly = totalEBOnly + EBOnly;
end

%% Output the summary
fprintf('Totals: Both:%d, PNCOnly:%d, EBOnly:%d\n', ...
        totalBoth, totalPNCOnly, totalEBOnly);
