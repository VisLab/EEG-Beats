 function [peakFrames, flip, sigRight] = getHeartBeats(ekg, twoSided, params)
% Find heartbeats in an ekg signal
%  
% Parameters:
%   ekg       ekg signal
%   params    structure with algorithm parameters (use printParams to see)
%   peakFrames (output) vector with frame numbers of the peaks
%   peakTimes  (output) vector with times in seconds of the peaks
%   peakAmplitudes (output) vector with peak amplitudes (positive numbers)
%
 
%% Set up variables
% Use initialParseIBI to find a preliminary estimate of the peaks.
% minimum qrs duration is how wide the peak should be
peakFrames = []; sigRight = -1;
qrsFrames = round(params.qrsDuration*params.srate);
ekg = ekg - median(ekg);
ekgAll = ekg;

%% First truncate signal so extreme peaks don't affect the result.
% lowerMax = getAvgMin(ekg) - (params.stdTruncate*1.4826*mad(ekg,1));
% upperMax = getAvgMax(ekg) + (params.stdTruncate*1.4826*mad(ekg,1));
maxSignal = params.stdTruncate*1.4826*mad(ekg,1);
ekg(ekg < -maxSignal) = -maxSignal;
ekg(ekg > maxSignal) = maxSignal;

% Convert the rate and the time to index sizes in an array
minIBIFrames = max(round(params.ibiMinSeconds*params.srate), 1);
flipIntervalFrames = round(params.flipIntervalLen * params.srate);
threshold = params.stdThreshold*1.4826*mad(ekg,1);

%% Determine whether or not to flip the ekg signal
flip = getFlipDirection(ekg, flipIntervalFrames, threshold);
if flip == -1
    return;
elseif flip > 0
    ekg = -ekg;
end

%upperLargeThreshold = params.stdLargeThreshold*1.4826*mad(ekg,1);
if ~twoSided
    sigRight = getTroughSide(ekg, flipIntervalFrames, qrsFrames, threshold);
else
    sigRight = true;
end
if sigRight == -1
    return;
elseif ~sigRight 
    ekg = fliplr(ekg);
end

%% Get the fencepost peaks and determine which are valid
innerRange = (1 + qrsFrames):(length(ekg) - qrsFrames);
maxFrames = initialParseIBI(ekg(innerRange), params.consensusIntervals, minIBIFrames);
maxFrames = maxFrames + innerRange(1) - 1;

for k = 1:length(maxFrames)
    beatValue = getBeatValue(ekg, maxFrames(k), qrsFrames, threshold, twoSided);
    ekg = zeroOut(ekg, maxFrames(k), qrsFrames);
    if isempty(beatValue)
        maxFrames(k) = 0;
    end
end

maxFrames(maxFrames == 0) = [];
if isempty(maxFrames)
    warning('getHeartBeats failed to find an initial partition of beats');
    return;
end

% Array of suspected peaks given in sample numbers. Treated as a queue
peaksIdx = [1, maxFrames, length(ekg)];  
peakMask = false(1, length(ekg));
peakMask(maxFrames) = true;

%% Get the other peaks
while (length(peaksIdx) > 1) %Loop while suspected peaks exist
    thisSignal = ekg(peaksIdx(1):peaksIdx(2));
    [~, tempIdx] = max(thisSignal); 
    beatFrame = tempIdx + peaksIdx(1) - 1;
    if ekg(beatFrame) <  threshold
        peaksIdx = peaksIdx(2:end);
        ekg = zeroOut(ekg, beatFrame, qrsFrames);
        continue;
    end

    beatValue = getBeatValue(thisSignal, tempIdx, qrsFrames, threshold, twoSided);
    if isempty(beatValue) || ...
       peaksIdx(1) ~= 1 && (peaksIdx(1) + minIBIFrames > beatFrame) ||...
       peaksIdx(2) ~= length(ekg) && (peaksIdx(2) - minIBIFrames < beatFrame) 
       valid = false;
    else
        valid = true;
    end
    ekg = zeroOut(ekg, beatFrame, qrsFrames);
    if valid
        peakMask(beatFrame) = 1;
        peaksIdx = [peaksIdx(1), beatFrame, peaksIdx(2:end)];
    end
end

if ~sigRight
    peakMask = fliplr(peakMask);
end
peakFrames = find(peakMask);
if flip
    ekgAll = -ekgAll;
end
peakFrames = adjustPeaks(peakFrames, ekgAll, maxSignal, qrsFrames); 