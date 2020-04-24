%% Script to calculate IBI indicators

%% Set the files
ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_10\ekgPeaks.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
ibiFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_10\ibiIndicators.mat';

baseParams = struct();
baseParams.figureVisibility = 'off';
baseParams.doPlot = false;

%% Set up the structure

ibis = struct('fileName', NaN, 'subName', NaN, 'blockMins', NaN, ...
              'fileMins', NaN, 'overallStats', NaN, 'blockedStats', NaN);
          


%% Load the heartbeat peaks
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
numFiles = length(ekgPeaks);

%% Initialize the structure
ibis(numFiles) = ibis(1);
params = baseParams;
[params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
if ~isempty(errors)
        error('Bad parameters: %s error messages', length(errors));
end

%% Now step through each file and compute the indicators
for n = 1%:numFiles
    ibis(n) = ibis(end);
    ibis(n).fileName = ekgPeaks(n).fileName;
    ibis(n).subName = ekgPeaks(n).subName;
    
end    