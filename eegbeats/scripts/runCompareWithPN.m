%% Compare two sets of peaks eeg-beats and physionet

%% Set up the file names
pnFile = 'D:\Papers\Current\Heart\Nikki\Comparisons\May26\physionetPeaks.mat';
ekgFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\ekgPeaks.mat';
rrInfoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\rrInfo.mat';
session = 1;
frameLimit = 5;

%% Load the frames
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
peakFrames1 = ekgPeaks(session).peakFrames;
temp = load(pnFile);
peakFrames2 = temp.physionetPeaks;


%% Compute the distances
dMat = pdist2(peakFrames1(:), peakFrames2(:));

%% Find the events that are matched to within frameLimit
[minValues1, minInd1] = min(dMat, [], 2);
[minValues2, minInd2] = min(dMat, [], 1);

%% Output 
fprintf('%d eegbeats peaks and %d PN peaks\n', ...
        length(peakFrames1), length(peakFrames2));
fprintf('%d eegbeats peaks not zero dist from PN peaks\n', sum(minValues1~=0));
fprintf('%d PN peaks not zero dist from PN peaks\n', sum(minValues2~=0));
fprintf('Distances eegBeats to closest PN: %s\n', count2str(minValues1));
fprintf('Distances PN to closest eegBeats %s\n', count2str(minValues2));

mask1 = minValues1 <= frameLimit;
matchedValues1 = peakFrames1(mask1);
matchedPos1 = peakFrames2(minInd1(mask1));
unMatchedDist1 = minValues1(~mask1);
unMatchedPeaks1 = peakFrames1(~mask1);
mask2 = minValues2 <= frameLimit;
matchedValues2 = peakFrames2(mask2);
unMatchedPeaks2 = peakFrames2(~mask2);
unMatchedDist2 = minValues2(~mask2);

%%
ekg = ekgPeaks(session).ekg;
srate = ekgPeaks(session).srate;

ts = 1:length(ekg);
ts = (ts - 1)./srate;


figure
plot(ts, ekg);
hold on
plot(ts(peakFrames1), ekg(peakFrames1), '*r')
plot(ts(peakFrames2), ekg(peakFrames2), 'sk', 'LineWidth', 1)
if ~isempty(unMatchedPeaks1)
    plot(ts(unMatchedPeaks1), ekg(unMatchedPeaks1), 'xr', ...
        'MarkerSize', 12, 'LineWidth', 1)
end
if ~isempty(unMatchedPeaks2)
     plot(ts(unMatchedPeaks2), ekg(unMatchedPeaks2), 'xk', ...
         'MarkerSize', 12, 'LineWidth', 1)
end
hold off
xlabel('Seconds')
ylabel('EKG')
title(['Session: ' num2str(session)]);
hold off
box on


