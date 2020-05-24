function peakFrames = adjustPeaks(peakFrames, ekg, maxSignal, qrsHalfFrames)
%% Adjusts peaks to actual maximum when original signal was clipped
peakAmps = ekg(peakFrames);

for k = 1:length(peakFrames)
    if peakAmps < maxSignal
        continue;
    end
    ind1 = max(1, peakFrames(k) - qrsHalfFrames);
    ind2 =  min(peakFrames(k) + qrsHalfFrames, length(ekg));
    [~, maxInd] = max(ekg(ind1:ind2));
    peakFrames(k) = ind1 + maxInd - 1;
end
