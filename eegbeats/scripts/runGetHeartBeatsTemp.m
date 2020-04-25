%% Find the heartbeat peak locations for a directory tree of EEG
%
% This finds all the EEG .set files in the directory tree rooted at rawDir
% and extracts heartbeats for all of the files and saves in the file
% peakFileName. The plotDir directory saves images of each ekg with peaks
% marked if plotting is specified.
%
% Execute showBeatDefaults() to see the default parameters and their
% values.
%

%% Set the paths
rawDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
peakFileName = 'D:\TestData\NCTU_RWN_VDE_IBIs_11\ekgPeaks.mat';
plotDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Images_11';

%% Set the base parameters (an empty structure uses the defaults)
baseParams = struct();

%% Get a list of all of the .set files in the directory tree of rawDir
EEGFiles = getFileAndFolderList(rawDir, {'*.set'}, true);
numFiles = length(EEGFiles);

%% Create session map
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    thePath = fileparts(EEGFiles{k});
    pieces = strsplit(thePath, filesep);
    sessionMap(pieces{end}) = k;
end

if ~isempty(plotDir) && ~exist(plotDir, 'dir')
    mkdir(plotDir);
end
if ~isempty(ekgDir) && ~exist(ekgDir, 'dir')
    mkdir(ekgDir);
end


%% Set up the structure for saving the peak and ekg information
ekgPeaks = getBeatStructs();
ekgPeaks(numFiles) = ekgPeaks(1);

%% Get the indicators
for n = 1:5%:numFiles
    nKey = num2str(n);
    if ~isKey(sessionMap, nKey)
        warning('Session %s does not have file', nKey);
        continue;
    end
    k = sessionMap(nKey);
    EEG = pop_loadset(EEGFiles{k});
    
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
    [params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
    if ~isempty(errors)
        error('Bad parameters: %s error messages', length(errors));
    end
    
    [ekgPeaks(n), hFig] = eeg_beats(EEG, theName, subName, params);
    
    %% Now save the information in the ekg file.
    if ~isempty(plotDir) && ~isempty(hFig)
        saveas(hFig, [plotDir filesep subName theName '.fig'], 'fig');
        saveas(hFig, [plotDir filesep subName theName '.png'], 'png');
        if strcmpi(params.figureVisibility, 'off')
            close(hFig)
        end
    end
end

%% Save the information if requested
if ~isempty(ekgDir)
    saveFile = [ekgDir filesep 'ekgPeaks.mat'];
    save(saveFile, 'ekgPeaks', '-v7.3');
end
if fd > 1
    fclose(fd);
end