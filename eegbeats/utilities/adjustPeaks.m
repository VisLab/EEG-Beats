function peakFrames = adjustPeaks(peakFrames, ekg, maxSignal, qrsHalfFrames)
%% Adjusts peaks to actual maximum when original signal was clipped
%
%  Parameters:
%     peakFrames    1-D array with positions of peaks in frames
%     ekg           array with ekg signal
%     maxSignal     value that the ekg was clipped at. 
%     qrsHalfFrames Maximum half-width in frames of a peak
peakAmps = ekg(peakFrames);

for k = 1:length(peakFrames)
    if abs(peakAmps(k)) < maxSignal
        continue;
    end
    ind1 = max(1, peakFrames(k) - qrsHalfFrames);
    ind2 =  min(peakFrames(k) + qrsHalfFrames, length(ekg));
    [~, maxInd] = max(ekg(ind1:ind2));
    peakFrames(k) = ind1 + maxInd - 1;
end
