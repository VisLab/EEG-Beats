function peakFrames = removeExtraPeaks(ekg, peakFrames, maxRRFrames)
%% Remove the small extra peaks in each method
    rrs = peakFrames(2:end) - peakFrames(1:end-1);
    rrs(rrs > maxRRFrames) = [];
    rrMedian = median(rrs);
    peakMask = false(size(peakFrames));
    for k = 2:length(peakFrames) - 1
        d3 = peakFrames(k + 1) - peakFrames(k - 1);
        if d3 > maxRRFrames || ...
           abs(ekg(peakFrames(k))) > abs(ekg(peakFrames(k - 1))) || ...
           abs(ekg(peakFrames(k))) > abs(ekg(peakFrames(k + 1))) 
            continue;
        end
        d1 = abs(peakFrames(k) - peakFrames(k - 1) - rrMedian);
        d2 = abs(peakFrames(k + 1) - peakFrames(k) - rrMedian);
        if abs(d3 - rrMedian) < max(d1, d2)
            peakMask(k) = true;
        end
    end
    peakFrames = peakFrames(~peakMask);