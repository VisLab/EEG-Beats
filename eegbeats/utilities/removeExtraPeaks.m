function [peakFramesNew, lowAmplitudePeaks, highAmplitudePeaks] = ...
                            removeExtraPeaks(ekg, peakFrames, params)
%% Remove the small extra peaks in each method (assumes oriented upward)
    if isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
        peakFramesNew = [];
        lowAmplitudePeaks = [];
        highAmplitudePeaks = [];
        return;
    end
    maxRRFrames = round(params.rrMaxMs.*params.srate./1000);
    rrs = peakFrames(2:end) - peakFrames(1:end-1);
    rrs(rrs > maxRRFrames) = [];
    rrMedian = median(rrs);
    peakMask = false(size(peakFrames));
    ekgM = ekg - median(ekg);
    ekgPcts = prctile(abs(ekgM(peakFrames)), [25, 50, 75]);
    rrsPcts = prctile(rrs, [25, 50, 75]);
    for k = 2:length(peakFrames) - 1
        d3 = peakFrames(k + 1) - peakFrames(k - 1);
        % Is RR interval large or is peak k bigger than its neighbors
        if d3 > maxRRFrames || ...
           abs(ekgM(peakFrames(k))) > abs(ekgM(peakFrames(k - 1))) || ...
           abs(ekgM(peakFrames(k))) > abs(ekgM(peakFrames(k + 1))) 
            continue;
        end
        d1 = abs(peakFrames(k) - peakFrames(k - 1) - rrMedian);
        d2 = abs(peakFrames(k + 1) - peakFrames(k) - rrMedian);
        if abs(d3 - rrMedian) < max(d1, d2)
            peakMask(k) = true;
        end
    end
    peakFramesNew = peakFrames(~peakMask);
    
    %% Small peaks at the beginning and end of the record are problematic
    rrsLowOutlier = rrsPcts(1) - params.maxWhisker*(rrsPcts(3) - rrsPcts(1));
    peakLowOutlier = ekgPcts(1) - params.maxWhisker*(ekgPcts(3) - ekgPcts(1));
    if rrs(1) < rrsLowOutlier && abs(ekgM(peakFramesNew(1))) < peakLowOutlier
       peakFramesNew(1) = [];
    end
    if rrs(end) < rrsLowOutlier && abs(ekgM(peakFramesNew(end))) < peakLowOutlier
       peakFramesNew(end) = [];
    end
    
    %% Mask again for remaining very small amplitudes
    medPeaks = median(ekg(peakFrames));  % Median of peaks in original
    lowMask = abs(ekgM(peakFramesNew)) < peakLowOutlier & ...
              abs(ekgM(peakFramesNew)) < params.minPeakAmpRatio*abs(medPeaks);
    lowAmplitudePeaks = peakFramesNew(lowMask);
 
    %% Mask for very high amplitudes
    peakHighOutlier = ekgPcts(3) + params.maxWhisker*(ekgPcts(3) - ekgPcts(1));

    highMask = abs(ekgM(peakFramesNew)) > peakHighOutlier & ...
              abs(ekgM(peakFramesNew)) > params.maxPeakAmpRatio*medPeaks;
    highAmplitudePeaks = peakFramesNew(highMask);
