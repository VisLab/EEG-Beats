function [allRRs, masks, maskTypes] = getRRsFromPeaks(peakFrames, lowAmpPeaks, highAmpPeaks, params)
%% Get the RRs from the peak frames with masks for different types
%
%  Parameters:
%     peakFrames   1-D array with peak positions in frames
%     lowAmpPeaks  1-D array with low amplitude peak positions
%     highAmpPeaks 1-D array with high amplitude peak positions
%     params       EEG-Beats parameters
%     allRRs       (Output) 2-D array with positions of second RR interval 
%                  peaks in first column and RR intervals in the second column
%     masks        (Output) n x M array with M masks in the column (n is # RRs)
%     maskTypes    (Output) Cell array of length M with the names of the masks
%
% Provides masks for different types of outlier detection for plotting and
% analysis
%% Initialize the output structures
numRRs = length(peakFrames(2:end));
allRRs = zeros(numRRs, 2);
allRRs(:, 1) = peakFrames(2:end);
allRRs(:, 2) = 1000*(peakFrames(2:end) - peakFrames(1:end-1))/params.srate;
 
 %% Calculate the mask for RRs too long or too short
 lowRRMask = false(length(peakFrames(2:end)), 1);
 highRRMask = false(size(lowRRMask));
 if params.removeOutOfRangeRRs
        lowRRMask(allRRs(:, 2) < params.rrMinMs) = true;
        highRRMask(allRRs(:, 2) > params.rrMaxMs) = true;
 end
 
 %% Calculate the mask for RRs around peaks that are too high or too low
 lowAmpRRMask = false(size(lowRRMask));
 highAmpRRMask = false(size(lowRRMask));
 if params.rrsAroundOutlierAmpPeaks 
     for k = 1:length(lowAmpPeaks)
         indPeak = find(peakFrames == lowAmpPeaks(k));
         if isempty(indPeak)
             continue;
         end
         indRRLow = max(1, indPeak - params.rrsAroundOutlierAmpPeaks);
         indRRHigh = min(length(lowAmpRRMask), ...
                    indPeak + params.rrsAroundOutlierAmpPeaks - 1);
         lowAmpRRMask(indRRLow:indRRHigh) = true;
     end
     for k = 1:length(highAmpPeaks)
         indPeak = find(peakFrames == highAmpPeaks(k));
         if isempty(indPeak)
             continue;
         end
         indRRLow = max(1, indPeak - params.rrsAroundOutlierAmpPeaks);
         indRRHigh = min(length(highAmpRRMask), ...
                    indPeak + params.rrsAroundOutlierAmpPeaks - 1);
         highAmpRRMask(indRRLow:indRRHigh) = true;
     end
 end     
         
%% Calculate the neighboorhood mask
badNeighborRRMask = false(size(lowRRMask));
maskSize = 2*params.rrOutlierNeighborhood + 1;
if params.rrOutlierNeighborhood ~= 0 && numRRs < maskSize
    warning('Not enough RRs to compute neighborhood outliers');
else
    lowFrac = (100 - params.rrPercentToBeOutlier)/100;
    highFrac = (100 + params.rrPercentToBeOutlier)/100;
    for k = 1:numRRs
        lowPos = max(1, k - params.rrOutlierNeighborhood);
        highPos = min(numRRs, k + params.rrOutlierNeighborhood);
        lowDeficit = max(0, params.rrOutlierNeighborhood - k + 1);
        highDeficit = max(0, params.rrOutlierNeighborhood + k - numRRs);
        lowPos = lowPos - highDeficit;
        highPos = highPos + lowDeficit;
        neighborMean = (sum(allRRs(lowPos:highPos, 2)) - allRRs(k, 2))/(maskSize - 1);
        if neighborMean*lowFrac > allRRs(k, 2) || allRRs(k, 2) > neighborMean*highFrac
            badNeighborRRMask(k) = true;
        end
    end
end
maskTypes = {'LowRR', 'HighRR', 'LowAmpRR', 'HighAmpRR', 'BadNeighborRR'};
masks = [lowRRMask(:), highRRMask(:), lowAmpRRMask(:), ...
         highAmpRRMask(:), badNeighborRRMask(:)];
