function [peakFramesNew, lowAmplitudePeaks] = ...
    removeExtraPeaks(ekg, peakFrames, maxRRFrames, minPeakAmpRatio)
%% Remove the small extra peaks in each method (assumes oriented upward)
    if isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
        peakFramesNew = [];
        lowAmplitudePeaks = [];
        return;
    end
    rrs = peakFrames(2:end) - peakFrames(1:end-1);
    rrs(rrs > maxRRFrames) = [];
    rrMedian = median(rrs);
    peakMask = false(size(peakFrames));
    ekgM = ekg - median(ekg);
    ekgPcts = prctile(abs(ekgM(peakFrames)), [25, 75]);
    rrsPcts = prctile(rrs, [25, 75]);
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
    
    %% Now handle peaks at the beginning and end of the record
    rrsOutlier = rrsPcts(1) - 1.5*(rrsPcts(2) - rrsPcts(1));
    peakOutlier = ekgPcts(1) - 1.5*(ekgPcts(2) - ekgPcts(1));
    if rrs(1) < rrsOutlier && abs(ekgM(peakFramesNew(1))) < peakOutlier
       peakFramesNew(1) = [];
    end
    if rrs(end) < rrsOutlier && abs(ekgM(peakFramesNew(end))) < peakOutlier
       peakFramesNew(end) = [];
    end
    
    %% Now mask again for remaining very small amplitudes
    lowMask = abs(ekgM(peakFramesNew)) < peakOutlier & ...
              abs(ekgM(peakFramesNew)) < minPeakAmpRatio*abs(ekgPcts(2));
    lowAmplitudePeaks = peakFramesNew(lowMask);
 
