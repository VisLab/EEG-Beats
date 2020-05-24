function hFig = makePeakDistributionPlot(ekgPeaks, baseTitle, params)   
%% Creates a figure of peak amplitude versus rr interval 

%% Set up the empty figure in case there is no data
    hFig = figure('Name', baseTitle, 'Visible', params.figureVisibility);
    set(hFig, 'Position', [840, 695, 720, 645]);
    title({ekgPeaks.fileName; baseTitle}, 'Interpreter', 'None')
    xlabel('ekg peak value')
    ylabel('rr interval (ms)')
    box on
    
    %% Extract the data and calculate percentiles for plotting
    ekg = ekgPeaks.ekg;
    peakFrames = ekgPeaks.peakFrames;
    if isempty(ekg) || (isscalar(ekg) && isnan(ekg)) || ...
       isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
       warning('%s: does not have any heart beats', params.fileName);
       return;
    end
    peakPrts = prctile(ekg(peakFrames), [25, 50, 75]);
    rrs = 1000*(peakFrames(2:end) - peakFrames(1:(end - 1)))/params.srate;
    rrsPrts = prctile(rrs, [25, 50, 75]);
    toprrs = rrsPrts(3) + 1.5*(rrsPrts(3) - rrsPrts(1));
    botrrs = rrsPrts(1) - 1.5*(rrsPrts(3) - rrsPrts(1));
    topPeak = peakPrts(3) + 1.5*(peakPrts(3) - peakPrts(1));
    botPeak = peakPrts(1) - 1.5*(peakPrts(3) - peakPrts(1));
    peaksLeft = peakFrames(1:end-1);
    peaksRight = peakFrames(2:end);
    
    %% Now do the graph if there is data
    leftColor = [0, 0, 0];
    rightColor = [0.1, 0.4, 0.8];
    leftMarker = 's';
    rightMarker = '*';
    hold on;
    plot(ekg(peaksLeft), rrs, 'Marker', leftMarker, 'Color', leftColor, ...
        'MarkerSize', 12,  'LineStyle', 'None', 'LineWidth', 1)
    plot(ekg(peaksRight), rrs, 'Marker', rightMarker, ...
        'Color', rightColor, 'MarkerSize', 10,  'LineStyle', 'None');
  
    set(gca, 'YLim', [params.rrMinMs, params.rrMaxMs]);
    xLims = get(gca, 'XLim');
    lowLim = max(xLims(1),  peakPrts(1) - 3*(peakPrts(3) - peakPrts(1)));
    highLim = min(xLims(2), peakPrts(3) + 3*(peakPrts(3) - peakPrts(1)));
    
    %% Now plot clipped outliers
    plotMasked(ekg(peaksLeft) < lowLim, lowLim, leftColor, leftMarker)
    plotMasked(ekg(peaksRight) < lowLim, lowLim, rightColor, rightMarker)
    plotMasked(ekg(peaksLeft) > highLim, highLim, leftColor, leftMarker)
    plotMasked(ekg(peaksRight) > highLim, highLim, rightColor, rightMarker)

    %% Reset the axis
    set(gca, 'XLim', [lowLim, highLim]);
    axis square
    yLims = get(gca, 'YLim');
    xLims = get(gca, 'XLim');
    
    %% Plot the interquartile ranges
    line([xLims(1), xLims(2)], [rrsPrts(1), rrsPrts(1)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    line([xLims(1), xLims(2)], [rrsPrts(2), rrsPrts(2)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0, 0.8, 0]);
    line([xLims(1), xLims(2)], [rrsPrts(3), rrsPrts(3)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    line([peakPrts(1), peakPrts(1)], [yLims(1), yLims(2)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    line([peakPrts(2), peakPrts(2)], [yLims(1), yLims(2)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0, 0.8, 0]);
    line([peakPrts(3), peakPrts(3)], [yLims(1), yLims(2)], 'LineWidth', 1, ...
        'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    
    %% Plot the fences

    line([xLims(1), xLims(2)], [botrrs, botrrs], 'LineWidth', 1, ...
         'LineStyle', '--', 'Color', [0.7, 0.7, 0.7]);
    line([xLims(1), xLims(2)], [toprrs, toprrs], 'LineWidth', 1, ...
         'LineStyle', '--', 'Color', [0.7, 0.7, 0.7]);

    line([topPeak, topPeak], [yLims(1), yLims(2)], 'LineWidth', 1, ...
            'LineStyle', '--', 'Color', [0.7, 0.7, 0.7]);
    line([botPeak, botPeak], [yLims(1), yLims(2)], 'LineWidth', 1, ...
            'LineStyle', '--', 'Color', [0.7, 0.7, 0.7]);
    hold off
    
    h = legend('Peak to left', 'Peak to right', 'Location', 'SouthWest');
    h1 = get(h, 'String');
    h1 = h1(1:2);
    set(h, 'String', h1);
    
    function [] = plotMasked(mask, theValue, theColor, theMarker)
        if sum(mask) > 0
            rrsMasked = rrs(mask);
            plot(repmat(theValue, size(rrsMasked)), rrsMasked, ...
                'Marker', theMarker, 'Color', theColor, ...
                'LineStyle', 'None', 'MarkerSize', 12, 'LineWidth', 1)
        end
    end
end