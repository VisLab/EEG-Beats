function [rrInfo, params] = eeg_ekgstats(ekgPeaks, params)
% Compute the rrInfo structure from the ekgPeaks structure

%% Check the parameters
[params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
if ~isempty(errors)
    error(['eeg_ekgstats has invalid input parameters' cell2str(errors)]);
end

%% Get the empty structures an fill in basic information
[~, rrInfo, RRMeasures] = getEmptyBeatStructs();
rrInfo.fileName = ekgPeaks.fileName;

ekg = ekgPeaks.ekg;
if isempty(ekgPeaks.ekg) || ...
        ((length(ekgPeaks.ekg) <= 1) && isnan(ekgPeaks.ekg)) || ...
        isempty(ekgPeaks.peakFrames) || ....
        ((length(ekgPeaks.peakFrames) <= 1) && isnan(ekgPeaks.peakFrames))
    return;
end
srate = ekgPeaks.srate;
ekgMinutes = length(ekg)/60.0/srate;
peakFrames = ekgPeaks.peakFrames;
lowAmpPeaks = ekgPeaks.lowAmplitudePeaks;
highAmpPeaks = ekgPeaks.highAmplitudePeaks;
rrInfo.fileMinutes = ekgMinutes;
rrInfo.blockMinutes = min(ekgMinutes, params.rrBlockMinutes);

%% Get the RRs and the artifact masks
[allRRs, masks, maskTypes] = ...
    getRRsFromPeaks(peakFrames, lowAmpPeaks, highAmpPeaks, params);

%% Should out-of-range RRs be removed?
if params.removeOutOfRangeRRs
    outOfRangeRRMask = masks(:, strcmpi(maskTypes, 'LowRR')) | ...
        masks(:, strcmpi(maskTypes, 'HighRR'));
else
    outOfRangeRRMask = false(size(allRRs, 1), 1);
end
removeMask = outOfRangeRRMask;

%% Should RRs around outlier peaks be removed?
if params.RRsToRemoveAroundOutlierAmpPeaks > 0
    outOfRangePeakRRMask = masks(:, strcmpi(maskTypes, 'LowAmpRR')) | ...
        masks(:, strcmpi(maskTypes, 'HighAmpRR'));
else
    outOfRangePeakRRMask = false(size(allRRs, 1), 1);
end
removeMask = removeMask | outOfRangePeakRRMask;

%% Should RRs that don't agree with neighbors be removed?
if params.RROutlierNeighborhood > 0
    neighborRRMask = masks(:, strcmpi(maskTypes, 'BadNeighborRR'));
else
    neighborRRMask = false(size(allRRs, 1), 1);
end
removeMask = removeMask | neighborRRMask;
RRs = allRRs(~removeMask, :);

%% Compute the overall measures
overallValues = getRRMeasures(RRs, rrInfo.fileMinutes, params);
overallValues.totalRRs = size(allRRs, 1);
overallValues.meanHR = overallValues.totalRRs./rrInfo.fileMinutes;
overallValues.numRemovedOutOfRangeRRs= sum(outOfRangeRRMask);
overallValues.numRemovedBadNeighbors = sum(neighborRRMask);
overallValues.numRemovedAroundOutlierAmpPeaks = sum(outOfRangePeakRRMask);
rrInfo.blockStepMinutes = min(ekgMinutes, params.rrBlockStepMinutes);
rrInfo.overallValues = overallValues;

%% Compute the block measures
numBlocks = floor((ekgMinutes - rrInfo.blockMinutes)/rrInfo.blockStepMinutes)+ 1;
blockM = RRMeasures;
blockM(numBlocks) = blockM(1);
startFrame = 1;
blockFrames = round(rrInfo.blockMinutes*60*srate);
blockStep = round(rrInfo.blockStepMinutes*60*srate);
for n = 1:numBlocks
    endFrame = startFrame + blockFrames - 1;
    rrMask = startFrame <= RRs(:, 1) &  RRs(:, 1) <= endFrame;
    b = getRRMeasures(RRs(rrMask, :), rrInfo.blockMinutes, params);
    blockM(n) = b;
    blockM(n).startMinutes = (startFrame - 1)/60/srate;
    
    %% Base some counts on RRs before artifact removal
    rrAllMask = startFrame <= allRRs(:, 1) &  allRRs(:, 1) <= endFrame;
    blockM(n).totalRRs = size(allRRs(rrAllMask, 1), 1);
    blockM(n).meanHR = blockM(n).totalRRs./rrInfo.blockStepMinutes;
    blockM(n).numRemovedOutOfRangeRRs= sum(outOfRangeRRMask(rrAllMask));
    blockM(n).numRemovedBadNeighbors = sum(neighborRRMask(rrAllMask));
    blockM(n).numRemovedAroundOutlierAmpPeaks = sum(outOfRangePeakRRMask(rrAllMask));  
    startFrame = startFrame + blockStep;
end
rrInfo.blockValues = blockM;