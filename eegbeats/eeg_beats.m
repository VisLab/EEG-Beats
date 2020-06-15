function [ekgPeaks, params, hFig1, hFig2] = eeg_beats(EEG, params)

    %% Set up the return values
    ekgPeaks = getEmptyBeatStructs();
    hFig1 = [];
    hFig2 = [];
    
    params = checkBeatDefaults(params, params, getBeatDefaults());
  
    if isfield(params, 'fileName')
       ekgPeaks.fileName = params.fileName;
    else
       ekgPeaks.fileName = 'Unknown source';
    end
    ekgPeaks.srate = params.srate;
    
    %% Now find the channel label
    channelMask = strcmpi({EEG.chanlocs.labels}, params.ekgChannelLabel);
    if sum(channelMask) == 0
        warning('%s: does not have an EKG channel', EEG.filename);
        return;
    end
    EEG.data = EEG.data(channelMask, :);
    EEG.chanlocs = EEG.chanlocs(channelMask);
    EEG.nbchan = 1;
    
    %% Downsample and filter the signal
    if EEG.srate > params.srate
        EEG = pop_resample(EEG, params.srate);
    end
    EEG = pop_eegfiltnew(EEG, params.filterHz(1),  params.filterHz(2));
    ekgPeaks.ekg = EEG.data;

    % Calculate the heart beats for two different methods
    [peakFrames, flip, sigRight] = getPeakFrames(EEG.data, false, params);
    peakSingleFrames = getPeakFrames(EEG.data, true, params);
    baseString = sprintf('Initially: peak-trough:%d, single-peak:%d, intersect:%d, flip:%d, sigRight:%d', ...
            length(peakFrames), length(peakSingleFrames), ...
            length(intersect(peakFrames, peakSingleFrames)), flip, sigRight);
    fprintf('%s\n', baseString);
   
    ekg = EEG.data - median(EEG.data);
    if flip
        ekg = -ekg;
    end
    
    %% Perform alignment of nearby peaks from two methods
    minRRFrames = round(params.rrMinMs.*params.srate./1000.0);
    [peakFrames, peakSingleFrames] = alignMethodFrames(ekg, peakFrames, peakSingleFrames, minRRFrames);
     if params.verbose
        fprintf('----after alignment: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
            length(peakFrames), length(peakSingleFrames), length(intersect(peakFrames, peakSingleFrames)));
     end
    
    %% Remove extra peaks in each representation individually
    
    peakFramesReduced = removeExtraPeaks(ekg, peakFrames, params);
    peakSingleFramesReduced = removeExtraPeaks(ekg, peakSingleFrames, params);
    if params.verbose
        fprintf('----after removal: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
            length(peakFramesReduced), length(peakSingleFramesReduced), ...
            length(intersect(peakFramesReduced, peakSingleFramesReduced)));
    end  
    
    %% Combine the peaks from the two methods and consider low amp peaks
    [peaksCombined, peaksRest] = combineMethodPeaks(peakFramesReduced, ...
                                     peakSingleFramesReduced, minRRFrames);
    [peaksCombinedFinal, lowAmplitudePeaks, highAmplitudePeaks] = ...
        removeExtraPeaks(ekg, peaksCombined, params);
    if params.verbose
        fprintf('----after combination: peaks:%d, peaks left:%d\n', ...
            length(peaksCombined), length(peaksRest));
        fprintf('----after final cleanup: peaks:%d\n', length(peaksCombinedFinal));
        if ~isempty(lowAmplitudePeaks)
           fprintf('----low amplitude peaks after cleanup: peaks:%d\n', length(lowAmplitudePeaks));
        end
        fprintf('\n');
    end
     
    if ~isempty(peaksCombinedFinal)
        ekgPeaks.peakFrames = peaksCombinedFinal;
        ekgPeaks.lowAmplitudePeaks = lowAmplitudePeaks;
        ekgPeaks.highAmplitudePeaks = highAmplitudePeaks;

    end
    
    %% Plot the data if requested
    if params.doPlot 
        baseString = sprintf(['peak-trough:%d, single:%d, ' ...
            'intersect:%d, combined: %d, cleaned: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
            length(peakFrames), length(peakSingleFrames), ...
            length(intersect(peakFrames, peakSingleFrames)), ...
            length(peaksCombined),  length(peaksCombinedFinal), ...
            length(peaksRest), flip, sigRight);
        hFig1 = makePeakPlot(ekgPeaks, baseString, params);
        hFig2 = makePeakDistributionPlot(ekgPeaks, baseString, params);
    end
    
    %% Save the figure if required
    if ~isempty(params.figureDir)
        if ~exist(params.figureDir, 'dir')
            mkdir(params.figureDir);
        end
        
        
        if ~isempty(hFig1)
            saveas(hFig1, [params.figureDir filesep params.fileName '_ekgPeaks.fig'], 'fig');
            saveas(hFig1, [params.figureDir filesep params.fileName '_ekgPeaks.png'], 'png');
        end
        if ~isempty(hFig2)
            saveas(hFig2, [params.figureDir filesep params.fileName '_rrVsPeaks.fig'], 'fig');
            saveas(hFig2, [params.figureDir filesep params.fileName '_RRVsPeaks.png'], 'png');
        end
    end
    
    %% Now handle figure closing if needed
    if strcmpi(params.figureVisibility, 'off') || params.figureClose
        close(hFig1)
        close(hFig2)
    end
    
end