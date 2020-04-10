%largePeaks = peakFrames(ekgTemp(peakFrames) > upperLargeThreshold);
% baseFrameMask = peakMask;
% baseFrameMask(ekgTemp(peakMask) < upperLargeThreshold) = false;
% 
% 
% h1 = figure('Name', 'Test');
% hold on
% plot(1:length(ekgTemp), ekgTemp)
% plot(maxFrames, ekgTemp(maxFrames), 'r*')
% plot(baseFrames(peakMask), ekgTemp(peakMask), 'gs', 'Markersize', 10)
% plot(largePeaks, ekgTemp(largePeaks), 'ko', 'Markersize', 10);
% hold off

% badPeakMask = false(size(peakFrames));
% peakFrames = round(peakFrames);
% peakAmps = ekgTemp(peakFrames);
% peakSlopes1 = zeros(size(peakFrames));
% peakSlopes2 = zeros(size(peakFrames));
% for k = 1:length(peakFrames)
%     ind1 = max(1, peakFrames(k) - 4);
%     ind2 = min(peakFrames(k) + 4, length(ekgTemp));
%     
%     delta1 = ekgTemp(peakFrames(k) - 1) - ekgTemp(ind1);
%     delta2 = ekgTemp(peakFrames(k) + 1) - ekgTemp(ind2);
%     peakSlopes1(k) = delta1/(peakFrames(k) - 1 - ind1);
%     peakSlopes2(k) = delta2/(peakFrames(k) + 1 - ind2);
% end
% 
% figure
% hold on
% plot(peakAmps, peakSlopes1, 'ok')
% plot(peakAmps, peakSlopes2, '*b')
% hold off
% 
% figure
% hold on
% plot(peakAmps, peakSlopes1./peakAmps, 'ok')
% plot(peakAmps, peakSlopes2./peakAmps, '*b')
% hold off
%%
