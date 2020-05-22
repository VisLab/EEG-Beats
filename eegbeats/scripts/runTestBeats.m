% if params.doPlot
%         baseString = sprintf(['peak-trough:%d, single:%d, ' ...
%             'intersect:%d, combined: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
%             length(peakFrames), length(peakSingleFrames), ...
%             length(intersect(peakFrames, peakSingleFrames)), ...
%             length(peaksCombined), length(peaksRest), flip, sigRight);

ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_new\ekgPeaks.mat';
rrInfoFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_new\rrInfo.mat';

temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
params = temp.params;

hFig = makePeakPlot(ekgPeaks(1).ekg, ekgPeaks(1).peakFrames, {'temp'}, params);