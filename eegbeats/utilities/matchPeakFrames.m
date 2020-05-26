% function [matched, unMatchedFirst, unMatchedSecond] = ...
%                        matchPeaks(peakFrames1, peakFrames2, frameLimit)
  
    dMat = pdist2(peakFrames1(:), peakFrames2(:));
    
    %% Find the events that are matched to within frameLimit
    [minValues1, minInd1] = min(dMat, [], 2);
    mask1 = minValues1 <= frameLimit;
    matchedValues1 = peakFrames1(mask1);
    matchedPos1 = peakFrames2(minInd1(mask1));
    unMatchedDist = minValues1(~mask1);
    unMatched1 = peakFrames1(~mask1);
    fprintf('%d unmatched predicted values min dist %g\n', ...
        length(unMatchedDist), min(unMatchedDist));
    
    
    %% Make sure that the matched values are unique
    [minValues2, minInd2] = min(dMat, [], 1);
    mask2 = minValues2 <= frameLimit;
    matchedValues2 = peakFrames2(mask2);
    unMatched2 = peakFrames2(~mask2); 
    if sum(matchedPos1 - unique(matchedValues2)) ~= 0
        error('Not unique match up of real and predicted events');
    end
    
    %%
    ekg = ekgPeaks(session).ekg;
    ts = 1:length(ekg);
    ts = (ts - 1)/ekgPeaks(session).srate;
    
    
    figure
    plot(ts, ekg);
    hold on
    plot(ts(peakFrames1), peakFrames1, '*r')
    plot(ts(peakFrames2), peakFrames2, 'sk', 'LineWidth', 1)
    hold off
    xlabel('Seconds')
    ylabel('EKG')
    title(['Session: ' num2str(session)]);
    hold off
    box on
    figure 
