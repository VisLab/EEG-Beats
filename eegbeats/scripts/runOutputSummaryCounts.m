%% Output basic statistics

% peakFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data1\ekgPeaks.mat';
% infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data1\rrInfo.mat';
peakFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\rrInfoWithRemoval.mat';
%% Load the files
temp = load(peakFile);
ekgPeaks = temp.ekgPeaks;
temp = load(infoFile);
rrInfo = temp.rrInfo;

%% First remove the datasets with noEKG
noEkgMask = false(length(ekgPeaks), 1);
noPeaksMask = false(length(ekgPeaks), 1);
for k = 1:length(ekgPeaks)
    if isscalar(ekgPeaks(k).ekg) && isnan(ekgPeaks(k).ekg)
        noEkgMask(k) = true;
    end
    if isscalar(ekgPeaks(k).peakFrames) && isnan(ekgPeaks(k).peakFrames)
        noPeaksMask(k) = true;
    end
end
fprintf('Total datasets: %d\n',  length(noEkgMask));
fprintf('Datasets no ekg: %d\n', sum(noEkgMask));
fprintf('Datasets no peaks: %d\n', sum(noPeaksMask));
ekgPeaks(noPeaksMask) = [];
rrInfo(noPeaksMask) = [];

%% Compute the counts
totalMinutes = 0;
totalBlocks = 0;
totalPeaks = 0;
totalLowPeaks = 0;
totalHighPeaks  = 0;
totalRRs = 0;
totalOutOfRangeRRs = 0;
totalBadNeighborRRs = 0;
totalAroundOutlierAmpPeaks = 0;
totalRemainingRRs = 0;
for k = 1:length(rrInfo)
    overallVals = rrInfo(k).overallValues;
    if ~isstruct(overallVals) && isnan(overallVals)
        continue;
    end
    totalRRs = totalRRs + overallVals.totalRRs;
    totalOutOfRangeRRs = totalOutOfRangeRRs + overallVals.numRemovedOutOfRangeRRs;
    totalBadNeighborRRs = totalBadNeighborRRs + overallVals.numRemovedBadNeighbors;
    totalAroundOutlierAmpPeaks = totalAroundOutlierAmpPeaks + ...
        overallVals.numRemovedAroundOutlierAmpPeaks;
    totalRemainingRRs = totalRemainingRRs + overallVals.numRRs;
    totalPeaks = totalPeaks + length(ekgPeaks(k).peakFrames);
    totalLowPeaks = totalLowPeaks + length(ekgPeaks(k).lowAmplitudePeaks);
    totalHighPeaks = totalHighPeaks + length(ekgPeaks(k).highAmplitudePeaks);
    totalMinutes = totalMinutes + rrInfo(k).fileMinutes;
    totalBlocks = totalBlocks + length(rrInfo(k).blockValues);
end

%% Output the results
fprintf('Total peaks:                    %15d\n', totalPeaks);
fprintf('Total minutes:                  %15.5f\n', totalMinutes);
fprintf('Total hours:                    %15.5f\n', totalMinutes/60);
fprintf('Total blocks:                   %15d\n', totalBlocks);
fprintf('Total low peaks:                %15d\n', totalLowPeaks);
fprintf('Total high peaks:               %15d\n', totalHighPeaks);
fprintf('Total RRs:                      %15d\n', totalRRs);
fprintf('Total out-of-range RRs:         %15d\n', totalOutOfRangeRRs);
fprintf('Total bad neighbor RRs:         %15d\n', totalBadNeighborRRs);
fprintf('Total around outlier amp peaks: %15d\n', totalAroundOutlierAmpPeaks);
fprintf('Total remaining RRs:            %15d\n', totalRemainingRRs);