%% Get the indicators for each EEG struct
% The following script performs several different tasks
% 1.   Get the ekg signal for each eeg file at the given filter
% 2.   Get the peaks and troughs for each signal
% 3.   Get the IBI indicators for each signal
% 4.   (optional) will plot each signal with the peaks and troughs marked

%% Set the paths
rawDataBaseDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
ekgDataBase = 'D:\TestData\NCTU_RWN_VDE_IBIs_7';
imageDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Images7';

params = struct();
params.srate = 128;
params.ibiMaxSeconds = 1.5;
params.ibiMinSeconds = 0.5;
params.filterHz = [3, 20];
params.stdTruncate = 15;
params.qrsDuration = 0.1;
params.flipIntervalLen = 2;
params.consensusIntervals = 31;
params.ekgChannelLabel = 'ekg';
params.stdThreshold = 1.5;
params.stdLargeThreshold = 5;
params.baseThreshold = 0;

%% Get a list of
EEGFiles = getFileAndFolderList(rawDataBaseDir, {'*.set'}, true);
numFiles = length(EEGFiles);

%% Create session map
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    thePath = fileparts(EEGFiles{k});
    pieces = strsplit(thePath, filesep);
    sessionMap(pieces{end}) = k;
end
    
% ekg signal
    % session, filename
    % srate, ekg signal array
ekgSignal(numFiles) = struct('subdirectory', NaN, 'filename', NaN, ...
    'srate', NaN, 'signal', NaN);

if ~exist(imageDir, 'dir')
    mkdir(imageDir);
end
if ~exist(ekgDataBase, 'dir')
    mkdir(ekgDataBase);
end
fd = fopen([ekgDataBase filesep 'summary.txt'], 'w');


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
    subPath = thePath(length(rawDataBaseDir) + 2:end);
    subPathSplit = strsplit(subPath, filesep);
    subName = '';
    if ~isempty(subPathSplit)
        for m = 1:length(subPathSplit)
            subName = [subName subPathSplit{m} '_']; %#ok<*AGROW>
        end
    end
        
    ekgSignal(k) = ekgSignal(end);
    ekgSignal(k).subdirectory = subPath;
    ekgSignal(k).filename = theName;
    
    %% Now find the channel label
    channelMask = strcmpi({EEG.chanlocs.labels}, params.ekgChannelLabel);
    if sum(channelMask) == 0
        warning('%d: %s does not have an EKG channel', k, EEGFiles{k});
        continue;
    end
    EEG.data = EEG.data(channelMask, :);
    EEG.chanlocs = EEG.chanlocs(channelMask);
    EEG.nbchan = 1;
    
    %% How downsample and filter the signal
    if EEG.srate > params.srate
        EEG = pop_resample(EEG, params.srate);
    end
    EEG = pop_eegfiltnew(EEG, params.filterHz(1),  params.filterHz(2));

    % Get the indicators
    [peakFrames, flip, sigRight] = getHeartBeats(EEG.data, false, params);
    [peakTwoFrames, flipTwo, sigRightTwo] = getHeartBeats(EEG.data, true, params);
    baseString = sprintf('%s: peak-trough:%d, two-sided:%d, intersect:%d, flip:%d, sigRight:%d', ...
            subPath, length(peakFrames), length(peakTwoFrames), ...
            length(intersect(peakFrames, peakTwoFrames)), flip, sigRight);
    fprintf(fd, '%s\n', baseString);
    if flip ~= flipTwo
        fprintf(fd,'----flipTwo not flip------\n');
    end
    ekg = EEG.data - median(EEG.data);
    if flip
        ekg = -ekg;
    end
    minIbiFrames = round(params.ibiMinSeconds.*params.srate);
    [peakFrames, peakTwoFrames] = alignMethodFrames(ekg, peakFrames, peakTwoFrames, minIbiFrames); 
    fprintf(fd, '----after alignment: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
           length(peakFrames), length(peakTwoFrames), length(intersect(peakFrames, peakTwoFrames)));
    
    maxIbiFrames = round(params.ibiMaxSeconds.*params.srate);
    peakFrames = removeExtraPeaks(ekg, peakFrames, maxIbiFrames);
    peakTwoFrames = removeExtraPeaks(ekg, peakTwoFrames, maxIbiFrames);
    fprintf(fd, '----after removal: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
           length(peakFrames), length(peakTwoFrames), length(intersect(peakFrames, peakTwoFrames)));
    [peakCombined, peakRest] = combineMethodPeaks(peakFrames, peakTwoFrames, minIbiFrames);
    fprintf(fd, '----after combination: peaks:%d, peaks left:%d\n', ...
           length(peakCombined), length(peakRest));
  
    %% Remove small extra peaks
    
%     peakAmps = abs(EEG.data(peakFrames));
%     peakAmps = abs(EEG.data(peakFrames));
%     figure
%     hist(peakAmps, 25)
%     iqrAmps = iqr(peakAmps);
%     medAmps = median(peakAmps)
%     qrsFrames = round(params.qrsDuration*params.srate);
%     ibiFrames = peakFrames(2:end) - peakFrames(1:end-1);
%     peakIbIs = NaN(2, length(peakFrames));
%     peakIbIs(1, 2:end) = ibiFrames;
%     peakIbIs(2, 1:end-1) = ibiFrames;
%     peakIbiMean = nanmean(peakIbIs);
%     figure
%     hist(ibiFrames, 25)
%         ekgPeaks(k).peakTm = peaksTm(1,:);
%         ekgPeaks(k).troughTm = peaksTm(2,:);
%         
%         % Generate the ibi
%     	[ibi, ibiErrorSummary(k).tooLarge, ibiErrorSummary(k).tooSmall] = ...
%             generateIBI(peaksTm(1,:), ibiMaxSeconds, ibiMinDist);
%         indicators = getIBIIndicators(ibi(:,2));        
    if length(peakFrames) > length(peakTwoFrames)
        bestFrames = peakFrames;
    else
        bestFrames = peakTwoFrames;
    end
    peakPrts = prctile(EEG.data(bestFrames), [25, 50, 75]);
    %% Plot the data if we want to
    doPlot = true;
    if doPlot
        medPeak = median(peakFrames);
        seconds = (0:(length(EEG.data) - 1))./params.srate;
        h = figure('Name', theName);
        hold on;
        plot(seconds, EEG.data);
        plot(seconds(peakCombined), EEG.data(peakCombined), 'r*', 'MarkerSize', 10);
        plot(seconds(peakFrames), EEG.data(peakFrames), 'ks');
        plot(seconds(peakTwoFrames), EEG.data(peakTwoFrames), 'kx', 'MarkerSize', 10);
      
        line([0, max(seconds)], [peakPrts(1), peakPrts(1)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
        line([0, max(seconds)], [peakPrts(2), peakPrts(2)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0, 0.8, 0]);
        line([0, max(seconds)], [peakPrts(3), peakPrts(3)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
        set(h, 'position', [0 0 2000 500])
        
        hold off
        baseString = sprintf(['%s: peak-trough:%d, two-sided:%d, ' ...
            'intersect:%d, combined: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
            subPath, length(peakFrames), length(peakTwoFrames), ...
            length(intersect(peakFrames, peakTwoFrames)), ...
            length(peakCombined), length(peakRest), flip, sigRight);
        title({baseString; theName}, 'Interpreter', 'None')
        xlabel('Seconds')
        ylabel('EKG signal')
        box on
        saveas(h, [imageDir filesep subName theName '.fig'], 'fig');
        saveas(h, [imageDir filesep subName theName '.png'], 'png');
        close(h)
    end
    fprintf(fd, '\n');

end
fclose(fd);