%% Consolidate IBI values

%% Set the paths
ekgDir = 'D:\TestData\NCTU_RWN_VDE_IBIs_8';
analysisDir = 'D:\TestData\NCTU_RWN_VDE_Analysis_8';

%% Make sure analysis directory exists
if ~exist(analysisDir, 'dir')
    mkdir(analysisDir);
end

%% Get a list of files
ekgFiles = getFileAndFolderList(ekgDir, {'*.mat'}, true);
numFiles = length(ekgFiles);

%% Create session map
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    [thePath, theName] = fileparts(ekgFiles{k});
    pieces = strsplit(theName, '_');
    sessionMap(pieces{2}) = k;
end

%% Create the ibi structure
ekg = struct('filename', NaN, 'srate', NaN, 'ekg', NaN, 'peakFrames', NaN);
ekg(numFiles) = ekg(1);

%% Get the indicators
for n = 1:numFiles
    nKey = num2str(n);
    if ~isKey(sessionMap, nKey)
        warning('Session %s does not have file', nKey);
        continue;
    end
    k = sessionMap(nKey);
    [thePath, theName, theExt] = fileparts(ekgFiles{k});
    temp = load(ekgFiles{k});
    ekg(n) = ekg(end);
    ekg(n).filename = theName;
    ekg(n).ekg = temp.ekg;
    ekg(n).srate = temp.srate;
    ekg(n).peakFrames = temp.peaksCombined;
end

%% Save the data
save([analysisDir filesep 'consolidatedEKG.mat'], 'ekg', '-v7.3');
   