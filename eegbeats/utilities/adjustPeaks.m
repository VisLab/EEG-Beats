function peakFrames = adjustPeaks(peakFrames, ekg, maxSignal, qrsFrames)

peakAmps = ekg(peakFrames);

for k = 1:length(peakFrames)
    if peakAmps < maxSignal
        continue;
    end
    ind1 = max(1, peakFrames(k) - qrsFrames);
    ind2 =  min(peakFrames(k) + qrsFrames, length(ekg));
    [~, maxInd] = max(ekg(ind1:ind2));
    newInd = ind1+maxInd - 1;
    if newInd ~= peakFrames(k)
        fprintf('Adjusting %d:%g to %d:%g\n', peakFrames(k), ekg(peakFrames(k)), ...
            newInd, ekg(newInd));
    end
    peakFrames(k) = ind1 + maxInd - 1;
end
