%% Compare EEG-Beat RR measures with previously computed PNC measures.

%% Set the file locations
infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\rrInfo.mat';
%infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\rrInfoWithRemoval.mat';
pncFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\physionetInfo.mat';
compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\EBPNCCompare.mat';
%compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\EBPNCCompareWithRemoval.mat';

%% Load the heartbeat peaks
temp = load(infoFile);
rrInfo = temp.rrInfo;
temp = load(pncFile);
pncInfo = temp.physioInfo;

%% Define the field dictionary
fields = {          
    'meanRR', 'NNmean'; ... 
    'medianRR', 'NNmedian'; ... 
    'skewRR', 'NNskew'; ... 
    'kurtosisRR', 'NNkurt'; ... 
    'iqrRR', 'NNiqr'; ... 
    'SDNN', 'SDNN'; ...      
    'RMSSD', 'RMSSD'; ...                 
    'pNN50','pnn50'; ... 
    'totalPower', 'ttlpwr'; ...   
    'VLF', 'vlf'; ...          
    'LF', 'lf'; ...           
    'LFnu', '-'; ...  
    'HF', 'hf'; ... 
    'HFnu', '-'; ...   
    'LFHFRatio', 'lfhf'};

lfnuPos = find(strcmpi(fields(:, 1), 'LFnu'));
hfnuPos = find(strcmpi(fields(:, 1), 'HFnu'));
lfPos = find(strcmpi(fields(:, 1), 'LF'));
hfPos = find(strcmpi(fields(:, 1), 'HF'));
tpPos = find(strcmpi(fields(:, 1), 'totalPower'));
vlfPos = find(strcmpi(fields(:, 1), 'VLF'));

%% Initialize the structure
numFields = size(fields, 1);
compareInfo = struct('EBName', NaN, 'PNCName', NaN, ...
                     'numEBs', NaN, 'numPNCs', NaN, 'numBoth', NaN, ...
                     'meanEB', NaN, 'meanPNC', NaN, ...
                     'stdEB', NaN, 'stdPNC', NaN, 'madEBPNC', NaN, ...
                     'EBValues', NaN, ...
                     'PNCValues', NaN, 'EBMask', NaN, 'PNCMask', NaN);
           
compareInfo(numFields) = compareInfo(1);
for k = 1:numFields
    compareInfo(k) = compareInfo(end);
    compareInfo(k).EBName = fields{k, 1};
    compareInfo(k).PNCName = fields{k, 2};
    compareInfo(k).EBValues = getFirstBlockValuesFromStructure(rrInfo, fields{k, 1});
    compareInfo(k).EBMask = ~isnan(compareInfo(k).EBValues);
    if strcmpi(fields{k, 2}, '-')
        continue;
    end
    compareInfo(k).PNCValues = getPNCValuesFromStructure(pncInfo, fields{k, 2});
    compareInfo(k).PNCMask = ~isnan(compareInfo(k).PNCValues);
end
compareInfo(hfnuPos).PNCValues = 100*compareInfo(hfPos).PNCValues./ ...
    (compareInfo(tpPos).PNCValues - compareInfo(vlfPos).PNCValues);
compareInfo(hfnuPos).PNCMask = ~isnan(compareInfo(hfnuPos).PNCValues);
compareInfo(lfnuPos).PNCValues = 100*compareInfo(lfPos).PNCValues./ ...
    (compareInfo(tpPos).PNCValues - compareInfo(vlfPos).PNCValues);
compareInfo(lfnuPos).PNCMask = ~isnan(compareInfo(lfnuPos).PNCValues);

%% Output the results
fprintf('Measure        numEB numPNC numBoth  meanEB  meanPNC stdEB stdPNC  madDiff\n'), ...
for k = 1:numFields
    EBMask = compareInfo(k).EBMask;
    PNCMask = compareInfo(k).PNCMask;
    bothMask = EBMask & PNCMask;
    EBVals = compareInfo(k).EBValues;
    EBVals = EBVals(bothMask);
    PNCVals = compareInfo(k).PNCValues;
    PNCVals = PNCVals(bothMask);
    madVals = mean(abs(EBVals - PNCVals));
    compareInfo(k).numEBs = sum(EBMask);
    compareInfo(k).numPNCs = sum(PNCMask);
    compareInfo(k).numBoth = sum(bothMask);
    compareInfo(k).meanEB = mean(EBVals);
    compareInfo(k).meanPNC =  mean(PNCVals);
    compareInfo(k).stdEB = std(EBVals);
    compareInfo(k).stdPNC = std(PNCVals);
    compareInfo(k).madEBPNC = madVals;
    fprintf('%15s     %d \t%d \t%d \t%g \t%g \t%g \t%g \t%g\n', ...
        compareInfo(k).EBName, compareInfo(k).numEBs, ...
        compareInfo(k).numPNCs, compareInfo(k).numBoth, ...
        compareInfo(k).meanEB, compareInfo(k).meanPNC, ...
        compareInfo(k).stdEB, compareInfo(k).stdPNC, ...
        compareInfo(k).madEBPNC);
end

%% Save the file
save(compareFile, 'fields', 'compareInfo', '-v7.3');