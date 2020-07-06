%% Script to calculate RR measures from an existing peaks summary

%% Set the files
ekgFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\rrInfo.mat';
%infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\rrInfoBadRemoved.mat';
pncFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\physionetInfo.mat';
compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\EBPNCCompare.mat';
%compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\EBPNCCompareBadRemoved.mat';
%% Load the heartbeat peaks
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
params = temp.params;
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
compareInfo = struct('EBName', NaN, 'PNCName', NaN, 'EBValues', NaN, ...
                     'PNCValues', NaN, 'EBMask', NaN, 'PNCMask', NaN);
compareInfo(numFields) = compareInfo(1);
for k = 1:numFields
    compareInfo(k) = compareInfo(end);
    compareInfo(k).EBName = fields{k, 1};
    compareInfo(k).PNCName = fields{k, 2};
    compareInfo(k).EBValues = getEBValuesFromStructure(rrInfo, fields{k, 1});
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
for k = 1:numFields
    EBMask = compareInfo(k).EBMask;
    PNCMask = compareInfo(k).PNCMask;
    bothMask = EBMask & PNCMask;
    EBVals = compareInfo(k).EBValues;
    EBVals = EBVals(bothMask);
    PNCVals = compareInfo(k).PNCValues;
    PNCVals = PNCVals(bothMask);
    MADVals = mean(abs(EBVals - PNCVals));
    fprintf(['%s: numEB:%d, numPNC:%d, numBoth:%d meanEB:%g, ' ...
              'meanPNC:%g, stdEB:%g stdPNC:%g MAD:%g\n'], ...
              compareInfo(k).EBName, sum(EBMask), sum(PNCMask), ...
              sum(bothMask), mean(EBVals), mean(PNCVals), ...
              std(EBVals), std(PNCVals), MADVals);
end

%% Save the file
save(compareFile, 'fields', 'compareInfo', '-v7.3');