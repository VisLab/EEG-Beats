%% Get the indicators for each EEG struct
% The following script performs several different tasks
% 1.   Get the ekg signal for each eeg file at the given filter
% 2.   Get the peaks and troughs for each signal
% 3.   Get the IBI indicators for each signal
% 4.   (optional) will plot each signal with the peaks and troughs marked

%% Set the paths
rawDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
ekgDir = 'D:\TestData\NCTU_RWN_VDE_IBIs_10';
plotDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Images_10';

%% Set the base parameters
baseParams = struct();
baseParams.figureVisibility = 'off';
baseParams.doPlot = false;
%% Get a list of files
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
if ~isempty(ekgDir)
    fd = fopen([ekgDir filesep 'summary.txt'], 'w');
else
    fd = 1;
end

%% Set up the structure for saving the peak and ekg information
ekgPeaks = struct('fileName', NaN, 'subName', NaN, 'srate', NaN, 'ekg', NaN, 'peakFrames', NaN);
ekgPeaks(numFiles) = ekgPeaks(1);

%% Get the indicators
for n = 1:numFiles
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

    %% Now find the channel label
    channelMask = strcmpi({EEG.chanlocs.labels}, params.ekgChannelLabel);
    if sum(channelMask) == 0
        warning('%d: %s does not have an EKG channel', k, EEGFiles{k});
        continue;
    end
    EEG.data = EEG.data(channelMask, :);
    EEG.chanlocs = EEG.chanlocs(channelMask);
    EEG.nbchan = 1;
    
    %% Downsample and filter the signal
    if EEG.srate > params.srate
        EEG = pop_resample(EEG, params.srate);
    end
    EEG = pop_eegfiltnew(EEG, params.filterHz(1),  params.filterHz(2));

    % Calculate the heart beats for two different methods
    [peakFrames, flip, sigRight] = getHeartBeats(EEG.data, false, params);
    [peakSingleFrames, flipSingle, sigRightSingle] = getHeartBeats(EEG.data, true, params);
    baseString = sprintf('%s: peak-trough:%d, single-peak:%d, intersect:%d, flip:%d, sigRight:%d', ...
            subPath, length(peakFrames), length(peakSingleFrames), ...
            length(intersect(peakFrames, peakSingleFrames)), flip, sigRight);
    fprintf(fd, '%s\n', baseString);
   
    ekg = EEG.data - median(EEG.data);
    if flip
        ekg = -ekg;
    end
    
    %% Perform alignment of nearby peaks from two methods
    minIbiFrames = round(params.ibiMinSeconds.*params.srate);
    [peakFrames, peakSingleFrames] = alignMethodFrames(ekg, peakFrames, peakSingleFrames, minIbiFrames);
     if params.verbose
        fprintf(fd, '----after alignment: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
            length(peakFrames), length(peakSingleFrames), length(intersect(peakFrames, peakSingleFrames)));
     end
    
    %% Remove extra peaks in each representation individually
    maxIbiFrames = round(params.ibiMaxSeconds.*params.srate);
    peakFrames = removeExtraPeaks(ekg, peakFrames, maxIbiFrames);
    peakSingleFrames = removeExtraPeaks(ekg, peakSingleFrames, maxIbiFrames);
    if params.verbose
        fprintf(fd, '----after removal: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
            length(peakFrames), length(peakSingleFrames), length(intersect(peakFrames, peakSingleFrames)));
    end  
    
    %% Combine the peaks from the two methods
    [peaksCombined, peaksRest] = combineMethodPeaks(peakFrames, peakSingleFrames, minIbiFrames);
    if params.verbose
        fprintf(fd, '----after combination: peaks:%d, peaks left:%d\n', ...
            length(peaksCombined), length(peaksRest));
        fprintf(fd, '\n');
    end
     
    %% Now save the information in the ekg file.
    ekgPeaks(n) = ekgPeaks (end);
    ekgPeaks(n).fileName = theName;
    ekgPeaks(n).subName = subName;
    ekgPeaks(n).srate = params.srate;
    ekgPeaks(n).ekg = EEG.data;
    ekgPeaks(n).peakFrames = peaksCombined;
  
    %% Plot the data if requested
    if params.doPlot
        baseString = sprintf(['%s: peak-trough:%d, single:%d, ' ...
            'intersect:%d, combined: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
            subPath, length(peakFrames), length(peakSingleFrames), ...
            length(intersect(peakFrames, peakSingleFrames)), ...
            length(peaksCombined), length(peaksRest), flip, sigRight);
        hFig = makePeakPlot(EEG.data, peaksCombined, {theName; baseString}, params);
        
        if ~isempty(plotDir)
            saveas(hFig, [plotDir filesep subName theName '.fig'], 'fig');
            saveas(hFig, [plotDir filesep subName theName '.png'], 'png');
            if strcmpi(params.figureVisibility, 'off')
                close(hFig)
            end
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