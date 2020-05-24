function peakSlopes = getPeakSlopes(ekg, peakFrames, params)

ekg = ekg - median(ekg);
qrsFrames = round(params.qrsDurationMs*params.srate/1000);
peakSlopes = nan(length(peakFrames), 2);
halfHeights = 0.5*ekg(peakFrames);
for k = 1:length(peakFrames)
    thisPeak = peakFrames(k);
    ind1 = find(ekg(thisPeak - qrsFrames:thisPeak - 1) >= halfHeights(k), 1, 'last');
    ind2 = find(ekg(thisPeak + 1: thisPeak + qrsFrames) <= halfHeights(k), 1, 'first');
end
    