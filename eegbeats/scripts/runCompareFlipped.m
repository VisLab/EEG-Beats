%% Calculate the peaks and create the images forcing flip or noflip for sessions
%

%% Set the base paths and specify which sessions
rawDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
peakFileBase = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\ekgPeaks.mat';
figureDirBase = 'D:\TestData\NCTU_RWN_VDE_Heart_Images2';
sessions = [221, 224, 225, 226, 238, 239, 240, 260, 262, 288, 293, 294, 295, 296, 297, 298];

%% Map the .set files in the directory tree of rawDir to sessions
EEGFiles = getFileAndFolderList(rawDir, {'*.set'}, true);
numFiles = length(EEGFiles);
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    [thePath, theName, ~] = fileparts(EEGFiles{k});
    pieces = strsplit(thePath, filesep);
    sessionMap(pieces{end}) = EEGFiles{k};
end

%% Make sure the directories exist
if ~isempty(peakFileBase)
    ekgDir = fileparts(peakFileBase);
    if ~isempty(ekgDir) && ~exist(ekgDir, 'dir')
        mkdir(ekgDir);
    end
end

%% Now do sessions for flip
flipFigDir = [figureDirBase filesep 'flip'];
if ~isempty(flipFigDir) && ~exist(flipFigDir, 'dir')
    mkdir(flipFigDir);
end
flipPeakFile = [peakFileBase 'Flip.mat'];

%% Set the base parameters (an empty structure uses the defaults)
baseParams = struct();
baseParams.figureVisibility = 'on';
baseParams.figureDir = flipFigDir;
baseParams.figureClose = true;
baseParams.flipDirection = 1;

%% Set up the structure for saving the peak and ekg information
ekgPeaks = getEmptyBeatStructs();
ekgPeaks(numFiles) = ekgPeaks(1);

%% Get the indicators
for k = sessions
    if ~isKey(sessionMap, num2str(k))
        warning('%d is not session with a file', k);
        continue;
    end
    EEGFile = sessionMap(num2str(k));
    EEG = pop_loadset(EEGFile);
    
    %% Split out the subdirectories to create names
    [thePath, theName, theExt] = fileparts(EEGFile);
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
    [ekgPeaks(k), params] = eeg_beats(EEG, params);
end
save(flipPeakFile, 'ekgPeaks', 'params', '-v7.3');

%% Now do for forcing no flip
noflipFigDir = [figureDirBase filesep 'noflip'];
if ~isempty(noflipFigDir) && ~exist(noflipFigDir, 'dir')
    mkdir(noflipFigDir);
end
noflipPeakFile = [peakFileBase 'Noflip.mat'];

%% Set the base parameters (an empty structure uses the defaults)
baseParams = struct();
baseParams.figureVisibility = 'on';
baseParams.figureDir = noflipFigDir;
baseParams.figureClose = true;
baseParams.flipDirection = -1;

%% Set up the structure for saving the peak and ekg information
ekgPeaks = getEmptyBeatStructs();
ekgPeaks(numFiles) = ekgPeaks(1);

%% Get the indicators
for k = sessions
    if ~isKey(sessionMap, num2str(k))
        warning('%d is not session with a file', k);
        continue;
    end
    EEGFile = sessionMap(num2str(k));
    EEG = pop_loadset(EEGFile);
    
    %% Split out the subdirectories to create names
    [thePath, theName, theExt] = fileparts(EEGFile);
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
    [ekgPeaks(k), params] = eeg_beats(EEG, params);
end
save(noflipPeakFile, 'ekgPeaks', 'params', '-v7.3');
