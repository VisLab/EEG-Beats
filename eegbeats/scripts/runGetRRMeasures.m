%% Script to calculate IBI measures from an existing peaks summary

%% Set the files
ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBI_Data\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_IBI_Data\rrInfo.mat';

%% Set up the structure templates
[~, rrInfo, rrMeasures] = getEmptyBeatStructs();

%% Load the heartbeat peaks
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
params = temp.params;
numFiles = length(ekgPeaks);

%% Initialize the structure
rrInfo(numFiles) = rrInfo(1);
[params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
if ~isempty(errors)
   error(['Bad parameters: ' cell2str(errors)]);
end

%% Now step through each file and compute the indicators
for k = 1:numFiles
    [rrInfo(k), params] = eeg_ekgstats(ekgPeaks(k), params);
end 

%% Save the ibiInfo file
save(infoFile, 'rrInfo', 'params', '-v7.3');