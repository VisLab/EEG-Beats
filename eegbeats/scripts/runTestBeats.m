% if params.doPlot
%         baseString = sprintf(['peak-trough:%d, single:%d, ' ...
%             'intersect:%d, combined: %d, unmatched: %d, flip:%d, sigRight:%d'], ...
%             length(peakFrames), length(peakSingleFrames), ...
%             length(intersect(peakFrames, peakSingleFrames)), ...
%             length(peaksCombined), length(peaksRest), flip, sigRight);

dataDir = 'D:\TestData\NCTU_RWN_VDE_Heart_Data';

temp = load([dataDir filesep 'ekgPeaks.mat']);
ekgPeaks = temp.ekgPeaks;
session = 2;
params = temp.params;
params.removeOutOfRangeRRs = true;
params.RRsToRemoveAroundOutlierAmpPeaks = 1;
params.RROutlierNeighborhood = 5;
params.RRPercentToBeOutlier = 20;
params.figureClip = 1;
peakFrames = ekgPeaks(session).peakFrames;
lowAmpPeaks = ekgPeaks(session).lowAmplitudePeaks; 
highAmpPeaks = ekgPeaks(session).highAmplitudePeaks;
[allRRs, masks] = getRRsFromPeaks(peakFrames, lowAmpPeaks, highAmpPeaks, params);
fprintf(['All:%d, lowRRs:%d, highRRs:%d, lowAmpRRs: %d, highAmpRRs:%d, '  ...
    'badNeighborRRs:%d\n'], length(allRRs), sum(masks.lowRRMask), ...
    sum(masks.highRRMask), sum(masks.lowAmpRRMask), ...
    sum(masks.highAmpRRMask), sum(masks.neighborRRMask));

%%

 
%% See if there is ekg to plot    
    ekg = ekgPeaks(session).ekg;
    peakFrames = ekgPeaks(session).peakFrames;
   if isempty(ekg) || (isscalar(ekg) && isnan(ekg)) 
       warning('%s: does not have any ekg', params.fileName);
       return;
   end

   
   
    %% See if there are peaks to plot 
    baseTitle = 'stuff';
    hFig = figure('Name', baseTitle, 'Visible', params.figureVisibility);
    if isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
        warning('%s: does not have any heart beats', params.fileName);
        return;
    end
        peakPrts = prctile(ekg(peakFrames), [25, 50, 75]);
       
            basePoint = max(abs(peakPrts));
            extremeLim = basePoint + abs(peakPrts(3) - peakPrts(1));
            ekg(ekg < -extremeLim) = -extremeLim;
            ekg(ekg > extremeLim) = extremeLim;
       
    
    %% We have ekg and RRs, so plot 

    seconds = (0:(length(ekg) - 1))./params.srate;
    rrTimes = (allRRs(:, 1) - 1)./params.srate;

    
   %[0 0.4470 0.7410] [0.8500 0.3250 0.0980]
    yyaxis left
    plot(seconds, ekg, 'Color', [0.8, 0.8, 0.8], 'LineStyle', '-')
        hold on
    plot(seconds(peakFrames), ekg(peakFrames), 'LineStyle', 'None', ...
        'Color', [0.6500 0.5250 0.2980], 'MarkerSize', 10, 'Marker', '*')
    set(gca, 'YColor', [0.6500 0.5250 0.2980]);
    ylabel('EKG signal', 'Color', [0.6500 0.5250 0.2980])
    xlabel('Seconds')
    hold off
    
    yyaxis right
    plot(rrTimes, allRRs(:, 2), 'sk', 'MarkerSize', 12, 'LineWidth', 1);
    hold on
    legendString = {'EEG', 'Peaks', 'RRs'};
    if sum(masks.neighborRRMask) > 0
    plot(rrTimes(masks.neighborRRMask), allRRs(masks.neighborRRMask, 2),  ...
        'Color', [0.4660, 0.6740, 0.1880], 'Marker','x', ...
        'LineWidth', 2, 'MarkerSize', 12, 'LineStyle', 'None');
    legendString{end + 1} = 'Bad neighbor';
    end
    
    outOfRangeRRs = masks.lowRRMask | masks.highRRMask;
   
    % 'Color', [ 0.4940, 0.1840, 0.5560]
    outOfRangePeakRRs = masks.lowAmpRRMask | masks.highAmpRRMask;
    if sum(outOfRangePeakRRs) > 0
    plot(rrTimes(outOfRangePeakRRs), allRRs(outOfRangePeakRRs, 2),  ...
        'o', 'LineWidth', 2, 'MarkerSize', 14, ...
        'Color', [0, 0.4470, 0.7410], 'LineStyle', 'None');
    legendString{end + 1} = 'Outlier peak RRs';
    end
    
    set(gca, 'YLim', [500, 1500], 'YColor', [0, 0, 0]);
    set(hFig, 'position', [0 0 2000 500])
    baseTitle = ['Peaks:' num2str(length(ekgPeaks)) ...
        ' Low peaks:' num2str(length(lowAmpPeaks)) ...
        ' High peaks:' num2str(length(highAmpPeaks)) ...
        ' Bad neighbor RRs:' num2str(sum(masks.neighborRRMask)) ...
        ' RRs around outlier peaks:'   num2str(sum(outOfRangePeakRRs)) ...
        ' out of range RRs: ' num2str(sum(outOfRangeRRs))];
        %d, bad neighbor RRs: %d, ...
        
    ylabel(gca, 'RR Intervals')
    set(gcf, 'Name', baseTitle)            
    title({ekgPeaks(session).fileName; baseTitle}, 'Interpreter', 'None')
    legend(legendString, 'Location', 'SouthOutside', 'Orientation', 'Horizontal')
    hold off
    box on
    %plot(seconds, ekg);
%     
%     %% If no peak frames, stop here
%     if isempty(peakPrts)
%         return;
%     end
% 
%     %% Plot the peaks
%     lowPeaks = ekgPeaks.lowAmplitudePeaks;
%     highPeaks = ekgPeaks.highAmplitudePeaks;
%     hold on;
%     plot(seconds(peakFrames), ekg(peakFrames), 'r*', 'MarkerSize', 10);
%     if ~isempty(lowPeaks) || ~isscalar(lowPeaks) || ...
%        (isscalar(lowPeaks) && ~isnan(lowPeaks))
%         plot(seconds(lowPeaks), ekg(lowPeaks), 'xk', ...
%             'MarkerSize', 12, 'LineWidth', 2)
%     end
%     if ~isempty(highPeaks) || ~isscalar(highPeaks) || ...
%        (isscalar(highPeaks) && ~isnan(highPeaks))
%         plot(seconds(highPeaks), ekg(highPeaks), '+k', ...
%             'MarkerSize', 12, 'LineWidth', 2)
%     end
%     line([0, max(seconds)], [peakPrts(1), peakPrts(1)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
%     line([0, max(seconds)], [peakPrts(2), peakPrts(2)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0, 0.8, 0]);
%     line([0, max(seconds)], [peakPrts(3), peakPrts(3)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
%     set(hFig, 'position', [0 0 2000 500])
%     title({ekgPeaks.fileName; baseTitle}, 'Interpreter', 'None')
%     xlabel('Seconds')
%     ylabel('EKG signal')
%     box on
%     
%     hold off

% hFig = makePeakPlot(ekgPeaks(1).ekg, ekgPeaks(1).peakFrames, {'temp'}, params);