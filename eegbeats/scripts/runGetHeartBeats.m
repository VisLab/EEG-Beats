%% Find the heartbeat peak locations for a directory tree of EEG
%
% This finds all the EEG .set files in the directory tree rooted at rawDir
% and extracts heartbeats for all of the files and saves in the file
% peakFile. The figureDir directory saves images of each ekg with peaks
% marked if plotting is specified. Since doIBIMeasures is set to false,
% no interbeat interval indicators are
%
% Execute outputBeatDefaults() to see the default parameters and their
% values.
%

%% Set the paths
rawDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
peakFile = 'D:\TestData\NCTU_RWN_VDE_IBI_Data\ekgPeaks.mat';
figureDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Images';

%% Set the base parameters (an empty structure uses the defaults)
baseParams = struct();
baseParams.figureVisibility = 'on';
baseParams.figureDir = figureDir;
baseParams.figureClose = true;

%% Get a list of all of the .set files in the directory tree of rawDir
EEGFiles = getFileAndFolderList(rawDir, {'*.set'}, true);
numFiles = length(EEGFiles);

%% Make sure the directories exist
if ~isempty(figureDir) && ~exist(figureDir, 'dir')
    mkdir(figureDir);
end
ekgDir = fileparts(peakFile);
if ~isempty(ekgDir) && ~exist(ekgDir, 'dir')
    mkdir(ekgDir);
end


%% Set up the structure for saving the peak and ekg information
ekgPeaks = getEmptyBeatStructs();
ekgPeaks(numFiles) = ekgPeaks(1);

%% Get the indicators
for k = 1:numFiles
    EEG = pop_loadset(EEGFiles{k});
    
    %% Split out the subdirectories to create names
    [thePath, theName, theExt] = fileparts(EEGFiles{k});
    subPath = thePath(length(rawDir) + 2:end);
    subPathSplit = strsplit(subPath, filesep);
    subName = '';
    if ~isempty(subPathSplit)
        subName = subPathSplit{1};
        for m = 2:length(subPathSplit)
            subName = [subName '_' subPathSplit{m}]; %#ok<*AGROW>
        end
    end
    params = baseParams;
    params.fileName = [subName '_' theName];
    [ekgPeaks(k), params, hFig] = eeg_beats(EEG, params);
end

%% Save the information if requested
if ~isempty(ekgDir)
    save(peakFile, 'ekgPeaks', 'params', '-v7.3');
end
