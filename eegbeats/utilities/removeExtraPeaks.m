function peakFrames = removeExtraPeaks(ekg, peakFrames, maxIbiFrames)
%% Remove the small extra peaks in each method
    ibis = peakFrames(2:end) - peakFrames(1:end-1);
    ibis(ibis > maxIbiFrames) = [];
    ibiMedian = median(ibis);
    peakMask = false(size(peakFrames));
    for k = 2:length(peakFrames) - 1
        d3 = peakFrames(k + 1) - peakFrames(k - 1);
        if d3 > maxIbiFrames || ...
           abs(ekg(peakFrames(k))) > abs(ekg(peakFrames(k - 1))) || ...
           abs(ekg(peakFrames(k))) > abs(ekg(peakFrames(k + 1))) 
            continue;
        end
        d1 = abs(peakFrames(k) - peakFrames(k - 1) - ibiMedian);
        d2 = abs(peakFrames(k + 1) - peakFrames(k) - ibiMedian);
        if abs(d3 - ibiMedian) < max(d1, d2)
            peakMask(k) = true;
        end
    end
    peakFrames = peakFrames(~peakMask);