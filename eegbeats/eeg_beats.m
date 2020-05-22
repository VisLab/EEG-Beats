function [ekgPeaks, params, hFig] = eeg_beats(EEG, params)

    %% Set up the return values
    ekgPeaks = getEmptyBeatStructs();
    hFig = [];
    
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
    maxRRFrames = round(params.rrMaxMs.*params.srate./1000);
    peakFrames = removeExtraPeaks(ekg, peakFrames, maxRRFrames);
    peakSingleFrames = removeExtraPeaks(ekg, peakSingleFrames, maxRRFrames);
    if params.verbose
        fprintf('----after removal: peak-trough:%d, two-sided:%d, intersect:%d\n', ...
            length(peakFrames), length(peakSingleFrames), length(intersect(peakFrames, peakSingleFrames)));
    end  
    
    %% Combine the peaks from the two methods
    [peaksCombined, peaksRest] = combineMethodPeaks(peakFrames, peakSingleFrames, minRRFrames);
    if params.verbose
        fprintf('----after combination: peaks:%d, peaks left:%d\n', ...
            length(peaksCombined), length(peaksRest));
        fprintf('\n');
    end
     
    if ~isempty(peaksCombined)
        ekgPeaks.peakFrames = peaksCombined;
    end
    %% Plot the data if requested
    if params.doPlot
        baseString = sprintf(['peak-trough:%d, single:%d, ' ...
            'intersect:%d, combined: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
            length(peakFrames), length(peakSingleFrames), ...
            length(intersect(peakFrames, peakSingleFrames)), ...
            length(peaksCombined), length(peaksRest), flip, sigRight);
        hFig = makePeakPlot(EEG.data, peaksCombined, {ekgPeaks.fileName; baseString}, params);
    end
    
    %% Save the figure if required
    if isempty(hFig) 
        return;
    end
    if ~isempty(params.figureDir)
        if ~exist(params.figureDir, 'dir')
            mkdir(params.figureDir);
        end
        saveas(hFig, [params.figureDir filesep params.fileName '_ekgPeaks.fig'], 'fig');
        saveas(hFig, [params.figureDir filesep params.fileName '_ekgPeaks.png'], 'png');
    end
    if strcmpi(params.figureVisibility, 'off') || params.figureClose
        close(hFig)
    end

end