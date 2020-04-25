%% Script to calculate IBI indicators

%% Set the files
ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_11\ekgPeaks.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
ibiFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_11\ibiMeasures.mat';

%% Set up the structure templates
[~, ibiInfo, ibiMeasures] = getEmptyBeatStructs();

%% Load the heartbeat peaks
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
numFiles = length(ekgPeaks);

%% Initialize the structure
ibiInfo(numFiles) = ibiInfo(1);
params = struct();
[params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
if ~isempty(errors)
        error('Bad parameters: %s error messages', length(errors));
end

%% Now step through each file and compute the indicators
for k = 1:numFiles
    %% Set the file names in the structure
    ibiInfo(k) = ibiInfo(end);
    ibiInfo(k) = eeg_ekgstats(ekgPeaks(k), params);
end 

%% Save the ibiInfo file
save(ibiFile, 'ibiInfo', 'params', '-v7.3');